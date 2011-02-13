Ion
===

A search engine written in Ruby and uses Redis.

Ion is under a state merciless refactoring until it reaches a
useable feature set--use at your own risk :)

Testing
-------

    rvm 1.9.2-p136@ion --rvmrc --create
    redis-server
    rvm gemset import  # or install gems in .gems

    export REDIS_URL=redis://127.0.0.1:6379/0  # optional, this is the default
    rake test

Usage
-----

Ion needs Redis.

    require 'ion'
    Ion.connect url: 'redis://127.0.0.1:6379/0'

Any ORM will do. As long as you can hook it to update Ion's indices, you'll be fine.

    class Album < Ohm::Model
      include Ion::Entity
      include Ohm::Callbacks  # for `after` and `before`

      # Say you have these fields
      attribute :name
      attribute :artist

      # Set it up to be indexed
      ion {
        text :name
        metaphone :artist
      }

      # Just call these after saving/deleting
      after  :save,   :update_ion_indices
      before :delete, :delete_ion_indices
    end

Searching is easy:

    results = Album.ion.search {
      text :name, "Dancing Galaxy"
    }

    results = Album.ion.search {
      metaphone :artist, "Astral Projection"
    }

The results will be an `Enumerable` object. Go ahead and iterate as you normally would.

    results.each do |album|
      puts "Album '#{album.name}' (by #{album.artist})"
    end

You can also get the raw results easily.

    results.to_a  #=> [<#Album>, <#Album>, ... ]
    results.ids   #=> ["1", "2", "10", ... ]

Features
--------

### Custom indexing functions

    class Book < Ohm::Model
      attribute :name
      attribute :synopsis
      reference :author, Person

      ion {
        text(:author) { author.name }              # Supply your own indexing function
      }
    end

    Book.ion.search { text :author, "Patrick Suskind" }

### Nested conditions

By default, doing a `.search { ... }` does an `all_of` search (that is,
it must match all the given rules). You can use `any_of` and `all_of`, and
you may even nest them.

    Book.ion.search {
      all_of {
        text :name,     "perfume the story of a murderer"
        text :synopsis, "base note"
        any_of {
          text :tags, "fiction"
          text :tags, "thriller"
        }
      }
    }

### Important rules

You can make certain rules score higher than the rest. In this example,
if the search string is found in the name, it'll rank higher than if it
was found in the synopsis.

    Book.ion.search {
      any_of {
        score(5.0) { text :name, "Darkly Dreaming Dexter" }
        score(1.0) { text :synopsis, "Darkly Dreaming Dexter" }
      }
    }

### Boosting

You can define rules on what will rank higher.

This is different from score in such that it only boosts current results,
and doesn't add any. For instance, below, it will not show all "sale" items,
but will make any sale items in the current result set rank higher.

    Book.ion.search {
      text :name, "The Taking of Sleeping Beauty"
      boost(2.0) { text :tags, "sale" }
    }

(Note: it will add +2.0, not multiply by 2.0. Also, the number is optional.)

### Ranges

Limit your searches like so.

    results = Book.ion.search {
      text :author, "Anne Rice"
    }

    # Any of these will work.
    results.range from: 54, limit: 10
    results.range from: 3
    results.range page: 1, limit: 30
    results.range (0..3)
    results.range (0..-1)
    results.range from: 3, to: 9

    results.size      # This will not change even if you change the range...
    results.ids.size  # However, this will.

    # Reset
    results.range :all

Extending Ion
-------------

Override it with some fancy stuff.

    class Ion::Search
      def to_ohm
        set_key = model.key['~']['mysearch']
        ids.each { |id| set_key.sadd id }
        Ohm::Set.new(set_key, model)
      end
    end

    set = Album.ion.search { ... }.to_ohm

Or extend the DSL

    class Ion::Scope
      def keywords(what)
        any_of {
          text :title, what
          metaphone :artist, what
        }
      end
    end

    Album.ion.search { keywords "Foo" }

Features in the works
---------------------

Stuff that's not implemented yet, but will be.

    # TODO: search keyword blacklist
    Ion.options.ignored_words += %w(at it the)

    class Item < Model
      ion {
        text :title
        sort :title                    # TODO: Sorting
        number :stock                  # TODO: Indexing numbers
      }
    end

    Item.ion.search {                  # TODO: Quoted searching
      text :title, 'apple "MacBook Pro"'
    }

    results = Item.ion.search {
      any_of {
        text :title, "Mac book"
        text :title, "Macbook"
        number :stock, 3
        number :stock, gt: 3
      }
      exclude {                        # TODO: exclusions
        text :title, "Case"
      }
    }

    results.sort_by :title
    results.sort_by :score, [:author, :asc], :title

    results.facet_counts #=> { :name => { "Ape" => 2, "Banana" => 3 } } ??

Quirks
------

### Searching with arity

The search DSL may leave some things in accessible since the block will
be ran through `instance_eval` in another context. You can get around it
via:

    Book.ion.search { text :name, @name }        # fail
    Book.ion.search { |q| q.text :name, @name }  # good

Or you may also take advantage of Ruby closures:

    name = @name
    Book.ion.search { text :name, name }         # good

Ion
===

#### A search engine written in Ruby and uses Redis.

Ion is under a state merciless refactoring until it reaches a
useable feature set--use at your own risk :)

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

This is different from `score` (above) in such that it only boosts current
results, and doesn't add any. For instance, below, it will not show all
"sale" items, but will make any sale items in the current result set
rank higher.

This example will boost the score of sale items by x2.0.

    Book.ion.search {
      text :name, "The Taking of Sleeping Beauty"
      boost(2.0) { text :tags, "sale" }
    }

### Metaphones

Indexing via metaphones allows you to search by how something sounds like,
rather than with exact spellings.

    class Person < Ohm::Model
      attribute :name

      ion {
        metaphone :name
      }
    end

    Person.create name: "Stephane Michael Cook"

    # Any of these will work
    Person.ion.search { metaphone :name, 'stiefen michel cooke' }
    Person.ion.search { metaphone :name, 'steven quoc' }

### Ranges

Limit your searches like so:

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

### Numeric and boolean indices

    class Recipe < Ohm::Model
      attribute :serving_size
      attribute :kosher
      attribute :name

      ion {
        number  :serving_size         # Define a number index
        boolean :kosher
      }
    end

    Recipe.ion.search { boolean :kosher, true }

    Recipe.ion.search { number :serving_size, 1 }            # n == 1
    Recipe.ion.search { number :serving_size, gt:1 }         # n > 1
    Recipe.ion.search { number :serving_size, gt:2, lt:5 }   # 2 < n < 5
    Recipe.ion.search { number :serving_size, min: 4 }       # n >= 4
    Recipe.ion.search { number :serving_size, max: 10 }      # n <= 10

Boolean indexing is a bit forgiving. You can pass it a string
and it will try to guess what it means.

    a = Recipe.create kosher: true
    b = Recipe.create kosher: 'false'
    c = Recipe.create kosher: false
    d = Recipe.create kosher: 1
    e = Recipe.create kosher: 0

    Recipe.ion.search { boolean :kosher, true }  # Returns a and d

### Sorting

First, define a sort index in your model.

    class Element < Ohm::Model
      attribute :name
      attribute :protons
      attribute :electrons

      ion {
        sort   :name       # <-- like this
        number :protons
      }
    end

Now sort it like so. This will not take the search relevancy scores
into account.

    results = Element.ion.search { number :protons, gt: 3.5 }
    results.sort_by :name

Note that this sorting (unlike in Ohm, et al) is case insensitive,
and takes English articles into account (eg, "The Beatles" will
come before "Rolling Stones").

Stopwords
---------

Anything in `Ion.config.stopwords` will be ignored. It currently
has a bunch of default English stopwords (a, it, the, etc)

    # Configure it to use Polish stopwords
    Ion.config.stopwords = %w(a aby ach acz aczkolwiek aj tej z) # and so on

    # Same as searching for 'slow'
    Album.ion.search { text :title, "slow z tej" }

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

A RESTful [ion-server](http://github.com/rstacruz/ion-server) is under heavy development.

    # An Ion server instance
    Ion.connect ion: 'http://127.0.0.1:8082'

    # This will be done on the server
    Album.ion.search { ... }

Better support for European languages by transforming special characters. (`ü` => `ue`)

Other stuff that's not implemented yet, but will be:

    Item.ion.search {                  # TODO: Quoted searching
      text :title, 'apple "MacBook Pro"'
    }

    results = Item.ion.search {
      text :title, "Macbook"
      exclude {                        # TODO: exclusions
        text :title, "Case"
      }
    }

    results.sort_by :name, order: :desc  # TODO: descending sort

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

### Using with Sequel

Ion comes with an optional plugin for [Sequel](http://sequel.rubyforge.org) models.

    require 'ion/extras/sequel'

    class Author < Sequel::Model
      plugin :ion_indexable

      # Define indices
      ion { text :title }
    end

    Author.ion.search { .. }

### Using with Rails

For Rails 3/Bundler, add it to your Gemfile.

    # Gemfile
    gem 'ion', :require_as => 'ion/extras/activerecord'

Create an Ion config file.

    # config/ion.yml
    development:
      :url: redis://127.0.0.1:6579/0
    test:
      :url: redis://127.0.0.1:6579/1
    production:
      :url: redis://127.0.0.1:6579/1

Have it connect to Ion on startup.

    # config/initializers/ion.rb
    spec = YAML.load_file("#{Rails.root.to_s}/config/ion.yml")[Rails.env]
    Ion.connect spec  if spec

In your models:

    class Author < ActiveRecord::Base
      acts_as_ion_indexable

      # Define indices
      ion { text :title }
    end

(To do: maybe an `ion-rails` gem with generators et al)

Testing
-------

Install the needed gems.

    rvm 1.9.2-p136@ion --rvmrc --create
    rvm gemset import  # or install gems in .gems

Run the tests. This will automatically spawn Redis.

    rake test

Running benchmarks
------------------

First, populate the database. You need this to run the other benchmarks.
This will automatically spawn Redis.

    rake bm:spawn
    BM_SIZE=20000 rake bm:spawn     # If you want a bigger DB size

Then run the indexing benchmark. You will need this to run the other
benchmarks as well.

    rake bm:index

The other available benchmarks are:

    rake bm:search

Authors
=======

Ion is authored by Rico Sta. Cruz of Sinefunc, Inc.
See more of our work on [www.sinefunc.com](http://www.sinefunc.com)!

License
-------

Copyright (c) 2011 Rico Sta. Cruz.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

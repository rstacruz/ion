Ion
===

Search engine.

Don't use me!

Testing
-------

    rvm 1.9.2-p136@ion --rvmrc --create
    redis-server
    rvm gemset import  # or install gems in .gems
    rake test

Usage
-----

Ion needs Redis.

    require 'ion'
    Ion.connect 'redis://127.0.0.1:22222'

Any ORM will do.

    class Album < Ohm::Model
      include Ion::Entity
      include Ohm::Callbacks  # for `after`

      # Say you have these fields
      attribute :name
      attribute :artist

      # Set it up to be indexed
      ion {
        text :title
        metaphone :description
      }

      # Just call this after saving
      after :save, :update_ion_indices
    end

Then search like so!

    search = Album.ion.search {
      text :title, "Dancing Galaxy"
    }

    search = Album.ion.search {
      metaphone :artist, "Astral Projection"
    }

The search will be an `Enumerable` so just use it like so.

    search.each do |album|
      puts "Album '#{album.name}' (by #{album.artist})"
    end

You can also get the raw results easily.

    search.to_a  #=> [<#Album>, <#Album>, ... ]
    search.ids   #=> ["1", "2", "10", ... ]

More neat stuff
---------------

Custom:

    class Product < Ohm::Model
      reference :brand, Brand

      ion {
        text(:brand) { brand.name }
      }
    end

    Product.ion.search { text :brand, "Starfaux" }

Extending
---------

Override it with some fancy stuff.

    class Ion::Search
      def to_ohm_set
        # `key` is a key to a Redis set.
        Ohm::Set.new(key, model)
      end
    end

    set = Album.ion.search { ... }.to_ohm_set

Or extend the DSL

    class Ion::Search
      def keywords(what)
        text :title, what
        metaphone :artist, what
      end
    end

    Album.ion.search { keywords "Foo" }

Stuff that's not implemented yet
--------------------------------

...but will be.

    class Item < Model
      ion {
        text :title
        sort :title
        number :stock
      }
    end

    search = Item.ion.search {
      any_of {
        text :title, "Mac book"
        text :title, "Macbook"
        number :stock, 3
        number :stock, gt: 3
      }
      exclude {
        text :title, "Pro"
      }
    }

    search.sort_by :title

    search.range from: 54, limit: 10
    search.paginate page: 1, limit: 30
    search.pages

    search.facet_counts #=> { :name => { "Ape" => 2, "Banana" => 3 } } ??

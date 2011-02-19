To do list
----------

 - Server: implement indexing

 - Server: implement purge

 - Server: implement async indexing

 - Server tests: make the server purge, instead of doing it by itself

 - Client: implement `Ion.connect ion:`

 - Client: implement remote searching

 - Client: implement remote indexing

 - Fuzzy indexing for autocompletes

 - Test the Rails `acts_as_ion_indexable`

 - Test the Sequel `plugin :ion_indexable`

 - Number array indexing? (`ion { number :employee_ids }` + `employee_ids().is_a?(Array)`)

 - Text array indexing (`ion { list :tags }`)

 - Boolean indexing should be more forgiving

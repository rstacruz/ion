v0.0.2
------

Most of these changes are in preparation for a client/server architecture.

 * Make text and metaphone indices handle Unicode strings better.

 * Add speed benchmarks.

 * Defer actual searching until results are needed.

 * Implement (de)serialization of Searches and Options to hashes.

     * Implement `Search#to_hash`, (eg, `Album.search { .. }.to_hash`)
       and `#inspect`.

     * Implement `Options#to_hash`. (eg, `Album.ion.to_hash`)

     * Implement searching by a serialized hash. (eg, `Album.ion.search(hash)`)

     * Implement setting options by hash. (eg, `Album.ion(hash)` or `class Album; ion hash; end`)

 * Implement an `Ion::Wrapper` class so that your app does not need to be
   loaded to perform searches.

v0.0.1 -- Feb 13, 2011
----------------------

 * Initial release.
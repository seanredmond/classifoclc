# Classifoclc

Interface to OCLC's Classify service, "a FRBR-based prototype designed to
support the assignment of classification numbers and subject headings for books,
DVDs, CDs, and other types of materials." See the [OCLC
documentation](https://www.oclc.org/developer/develop/web-services/classify.en.html). Classifoclc
is aimed mainly at getting works from various other identifiers.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'classifoclc'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install classifoclc

## Usage

### Look ups

The easiest way to use `Classifoclc` is to lookup works by several standard identifiers:

* `Classifoclc::isbn`
* `Classifoclc::lccn`
* `Classifoclc::oclc`
* `Classifoclc::owi`

Each of these returns an `Enumerator` that can be looped over to get the
individual `Classifoclc::Work` objects. A "work" is an abstraction, and each
work has one or more editions. An "edition" is a physical (or digital) item that
can be held by a library. Fromt the `Classifoclc::Work` object you can get
several pieces of information, most usefully, perhaps, the number of editions
(`#edition_count`), the number of libraries that hold the work (`#holdings`) and
and that hold the work digitally (`#eholdings`), and the editions themselves (`#editions`)

    > works = Classifoclc::isbn("0151592659")
    > wrk = works.first
    > wrk.title
     => "Meridian"
    > wrk.owi
     => "201096"
    > wrk.format
     => "Book"
    > wrk.itemtype
     => "itemtype-book"
    > wrk.edition_count
     => 114
    > wrk.holdings
     => 3264
    > wrk.eholdings
     => 196
    > wrk.editions # Returns an Enumerator
    > wrk.authors # Returns an Array
    > wrk.recommendations # Returns a Recommendations object
    

A work has an array authors which seems to inlcude all the authors of all the
editions of a work, including their VIAF and LC identifiers:

    > work = Classifoclc::isbn("0151592659").first
    > auth = work.authors.first
    > auth.name
     => "Walker, Alice, 1944-"
    > auth.viaf
     => "108495772"
    > auth.lc
     => "n79109131"

You can also lookup by author(`Classifoclc::author`), title
(`Classifoclc::title`) and FAST identifier (`Classifoclc::fast`) but these can
return a _very large_ number of results that take a long time and thousands of
requests to return.

### Sort order

You can change how the results are sorted by passing an `:orderby` and/or
`:order` parameter to the lookup. `:orderby` can take one of the following
values:

|Contant|Meaning|
|-------|-------|
|`Classifoclc::OrderBy::EDITIONS`|Number of editions the work has (default)|
|`Classifoclc::OrderBy::HOLDINGS`|Number of libraries that hold the work|
|`Classifoclc::OrderBy::FIRSTYEAR`|Date of first edition|
|`Classifoclc::OrderBy::LASTYEAR`|Date of latest edition|
|`Classifoclc::OrderBy::LANGUAGE`|Language|
|`Classifoclc::OrderBy::HEADING`|FAST subject heading|
|`Classifoclc::OrderBy::WORKS`|Number of works with this FAST subject heading|
|`Classifoclc::OrderBy::SUBJTYPE`|FAST subject type|

`:order` can be either `Classifoclc::Order::ASC` (default) or `Classifoclc::Order::DESC`.

    > works = Classifoclc::isbn("0151592659", :orderby => Classifoclc::OrderBy::HOLDINGS, :order => Classifoclc::Order::DESC)
    
### Recommendations

Each `Work` has a set of recommended classifications available through the `#recommendations` method. This returns a `Recommendations` object

    > work = Classifoclc::isbn("0151592659").first
    > recs = work.recommendations
    
The recommendations include an array of FAST subject headings

    > recs.fast.first
     => {:heading=>"Southern States", :holdings=>"2945", :ident=>"1244550"}
     
LCC and Dewey Decimal recommendations are each hashes with the possible keys `:mostPopular`, `:mostRecent`, and `:latestEdition`. For each key the value is an array of recommended classifiers:

    > recs.lcc[:mostPopular].first
     => {:holdings=>"3221", :nsfa=>"PS3573.A425", :sfa=>"PS3573.A425"}
    recs.ddc[:mostPopular].first
     => {:holdings=>"2632", :nsfa=>"813.54", :sfa=>"813.54"}
     
For the meaning of the classifications, refer to the [OCLC documentation](https://www.oclc.org/developer/develop/web-services/classify/classification.en.html).

### Editions

Use the `#editions` method to get editions of a work. The method returns an `Enumerator`

    > work = Classifoclc::isbn("0151592659").first
    > work.edition_count
     => 114
    > work.editions.each do |ed|
     # 114 loops
    > end
    > ed = work.editions.first
    > ed.oclc
     => "2005960"
    > ed.title
     => "Meridian"
    > ed.format
     => "Book"
    > ed.itemtype
     => "itemtype-book"
    > ed.holdings
     => 1420
    > ed.eholdings
     => 0
    > ed.language
     => "eng"
    > ed.authors
     => "Walker, Alice, 1944-"
    > ed.classifications
     => [{:edition=>"0", :ind1=>"0", :ind2=>"0", :sf2=>"00", :sfa=>"813.54", :tag=>"082"}, {:ind1=>"0", :ind2=>"0", :sfa=>"PS3573.A425", :tag=>"050"}, {:ind1=>"0", :ind2=>"0", :sfa=>"PZ4.W176", :tag=>"050"}]
     
Note that `Edition#authors` just returns a string, _not_ return and Array of `Author` objects like `Work#authors`

For the meaning of the classifications, refer to the [OCLC documentation](https://www.oclc.org/developer/develop/web-services/classify/classification.en.html).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/seanredmond/classifoclc. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Classifoclc project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/seanredmond/classifoclc/blob/master/CODE_OF_CONDUCT.md).

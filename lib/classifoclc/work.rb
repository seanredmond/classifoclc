module Classifoclc
  # An abstract work. A work is not a physical book, but the
  # conceptual work of which all the physical books are manifestions
  class Work
    attr_reader :authors
    def initialize(node)
      @node = node
      @work = node.css('work').first
      @authors = node.css('author').
                   map{|a| Classifoclc::Author.new(a.text, a['lc'], a['viaf'])}
      @recommendations = load_recommendations(node)
    end

    # Get the work ID
    # @return [String]
    def owi
      @work['owi']
    end

    # Get the title
    # @return [String]
    def title
      @work['title']
    end

    # Get the format
    # @return [String]
    def format
      @work['format']
    end

    # Get the type of item
    # @return [String]
    def itemtype
      @work['itemtype']
    end

    # Get the number of editions the work has
    # @return [Integer]
    def edition_count
      @work['editions'].to_i
    end

    # Get the number of libraries that hold a copy of this work
    # @return [Integer]
    def holdings
      @work['holdings'].to_i
    end

    # Get the number of libraries that hold a digital copy of this work
    # @return [Integer]
    def eholdings
      @work['eholdings'].to_i
    end

    # Get the editions of this work
    # @return [Enumerator<Classifoclc::Edition>]
    def editions
      Enumerator.new do |e|
        pages.each do |pg|
          pg.each do |edition|
            e << edition
          end
        end
      end
    end

    # Get the recommended classifications for this work
    # @return [Array<Classifoclc::Recommendations>]
    def recommendations
      @recommendations
    end

    def full(hsh = {})
      params = {:identifier => 'owi', :value => owi,
                :summary => false}.merge(hsh)
      data = Classifoclc::fetch_data(params)
      editions = data.css('edition').map{|e| Edition::new(e)}

      navigation = data.css("navigation")

      next_page = nil
      unless navigation.empty?
        n = data.css("navigation next").first

        if n.nil?
          next_page = nil
        else
          next_page = n.text.to_i
        end
      end

      return {:editions => editions, :next => next_page}
    end

    # Iterate over pages of results
    def pages
      hsh = full()
      Enumerator.new do |page|
        page << hsh[:editions]
        loop do
          break if hsh[:next].nil?
          hsh = full(:startRec => hsh[:next])
          page << hsh[:editions]
        end
      end
    end

    def load_recommendations(node)
      recs = node.css('recommendations')
      return nil if recs.empty?

      return Recommendations.new(recs.first)
    end

    private :full, :pages, :load_recommendations
  end
end

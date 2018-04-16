require "pp"
module Classifoclc
  class Work
    attr_reader :authors
    def initialize(node)
      @node = node
      @work = node.css('work').first
      @authors = node.css('author').
                 map{|a| Classifoclc::Author.new(a.text, a['lc'], a['viaf'])}
    end

    def owi
      @work['owi']
    end

    def title
      @work['title']
    end

    def format
      @work['format']
    end

    def itemtype
      @work['itemtype']
    end

    def edition_count
      @work['editions'].to_i
    end

    def holdings
      @work['holdings'].to_i
    end

    def eholdings
      @work['eholdings'].to_i
    end

    def editions
      Enumerator.new do |e|
        pages.each do |pg|
          pg.each do |edition|
            e << edition
          end
        end
      end
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

    private :full, :pages
  end
end

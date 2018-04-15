module Classifoclc
  class Work
    attr_reader :authors
    def initialize(node)
      @node = node
      @work = node.css('work').first
      @authors = node.css('author').
                 map{|a| Classifoclc::Author.new(a.text, a['lc'], a['viaf'])}
      @editions = nil
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
      unless @editions.nil?
        return @editions
      end

      
      @editions = full
      return @editions
    end

    def full
      data = Classifoclc::fetch_data(:identifier => 'owi', :value => owi,
                                     :maxRecs => edition_count,
                                     :summary => false)
      editions = data.css('edition').map{|e| Edition::new(e)}
      return editions
    end

    private :full
  end
end

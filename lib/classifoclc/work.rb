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

      @editions = Classifoclc::lookup(:identifier => 'owi', :value => owi,
                                      :max => edition_count,
                                      :summary => false,
                                      :want_editions => true)
    end
  end
end

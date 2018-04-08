module Classifoclc
  class Work
    attr_reader :authors
    def initialize(node)
      @node = node
      @work = node.css('work').first
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

    def editions
      @work['editions'].to_i
    end

    def holdings
      @work['holdings'].to_i
    end

    def eholdings
      @work['eholdings'].to_i
    end
  end
end

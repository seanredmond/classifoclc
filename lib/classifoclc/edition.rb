module Classifoclc
  class Edition
    def initialize(node)
      @edition = node
    end

    def oclc
      @edition['oclc']
    end

    def authors
      @edition['author']
    end
    
    def title
      @edition['title']
    end

    def format
      @edition['format']
    end

    def itemtype
      @edition['itemtype']
    end

    def holdings
      @edition['holdings'].to_i
    end

    def eholdings
      @edition['eholdings'].to_i
    end

    def language
      @edition['language']
    end
  end
end
    

module Classifoclc
  class Edition
    attr_reader :classifications

    def initialize(node)
      @edition = node
      @classifications = load_classifications(node)
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

    def load_classifications(node)
      cls = node.css("classifications class")
      return nil if cls.empty?
      cls.map{|c| Hash[c.keys.map{|k| [k.to_sym, c[k]]}]}
    end

    private :load_classifications
  end
end
    

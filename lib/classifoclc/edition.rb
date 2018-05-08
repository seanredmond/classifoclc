module Classifoclc
  # An expression of a work. The physical books libraries held (or
  # their digitizations) are "manifestations" of these editions
  class Edition
    attr_reader :classifications

    def initialize(node)
      @edition = node
      @classifications = load_classifications(node)
    end

    # The OCLC number of the edition
    # @return [String]
    def oclc
      @edition['oclc']
    end

    # The author of the edition
    # @return [String]
    def authors
      @edition['author']
    end
    
    # The title of the edition
    # @return [String]
    def title
      @edition['title']
    end

    # The format of the edition
    # @return [String]
    def format
      @edition['format']
    end

    # The type of item the edition
    # @return [String]
    def itemtype
      @edition['itemtype']
    end

    # The number of libraries that hold a copy of this work
    # @return [Integer]
    def holdings
      @edition['holdings'].to_i
    end

    # The number of libraries that hold a digital copy of this work
    # @return [Integer]
    def eholdings
      @edition['eholdings'].to_i
    end

    # The language of item the edition
    # @return [String]
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
    

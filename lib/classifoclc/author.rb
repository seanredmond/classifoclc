module Classifoclc
  class Author
    attr_reader :name, :lc, :viaf
    def initialize(name, lc, viaf)
      @name = name
      @lc = lc
      @viaf = viaf
    end
  end
end

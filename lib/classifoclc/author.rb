module Classifoclc
  # Author of a Classifoclc::Work
  class Author
    # The author's name
    # @return [String]
    attr_reader :name

    # The author's Library of Congress id number
    # @return [String]
    attr_reader :lc

    # The author's VIAF number
    # @return [String]
    attr_reader :viaf
    def initialize(name, lc, viaf)
      @name = name
      @lc = lc
      @viaf = viaf
    end
  end
end

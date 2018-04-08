module Classifoclc
  class Work
    def initialize(node)
      @node = node
    end

    def owi
      @node['owi']
    end

    def title
      @node['title']
    end

    def format
      @node['format']
    end

    def itemtype
      @node['itemtype']
    end

    def editions
      @node['editions'].to_i
    end

    def holdings
      @node['holdings'].to_i
    end

    def eholdings
      @node['eholdings'].to_i
    end
  end
end

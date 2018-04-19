require "pp"
module Classifoclc
  class Recommendations
    attr_accessor :graphs, :fast
    
    def initialize(node)
      @graphs = load_graphs(node)
      @fast = load_fast(node)
    end

    def load_graphs(node)
      graphs = {}
      node.css("graph").each do |g|
        if g.parent.name == "recommendations"
          graphs[:all] = g.text
        else
          graphs[g.parent.name.to_sym] = g.text
        end
      end

      return graphs
    end

    def load_fast(node)
      node.css("fast heading").map{|h| { :heading => h.text,
                                         :holdings => h['heldby'],
                                         :ident => h['ident']}
      }
    end

    private :load_graphs, :load_fast
  end
end

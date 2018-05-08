module Classifoclc
  class Recommendations
    # A hash of links to Google Charts graphs showing the proportion
    # of libraries using which identifiers
    # @return [Hash]
    attr_accessor :graphs

    # Recommended FAST subject headings
    # @return [Hash]
    attr_accessor :fast

    # Recommended Dewey Decimal classifications
    # @return [Hash]
    attr_accessor :ddc

    # Recommended Library of Congress classifications
    # @return [Hash]
    attr_accessor :lcc
    
    def initialize(node)
      @graphs = load_graphs(node)
      @fast = load_fast(node)
      @ddc = load_classifications(node, 'ddc')
      @lcc = load_classifications(node, 'lcc')
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

    def load_classifications(node, e)
      return nil if node.css(e).empty?
      Hash[
        # Get to desired element
        node.css(e).
          # Pick out all it's children that are elements but aren't <graph>
          map{|d| d.children.
                select{|c| c.element? and c.name != "graph"}}.
          # It will be an Array containing one Array, so we just need to first
          # element (i.e. the inner Array)
          first.

          # There can be multiples of the same element, so group the Array by
          # element
          group_by{|c| c.name}.

          # Now we have a hash. Each key is the name of one of the child
          # elements of the element started with (ddc or lcc). The values are
          # hashes of all the elements with that name. 
          map{|k, v|
          [
            # Convert the names of the elements to symbols
            k.to_sym,
            # convert each element to a hash of its attributes where the
            # keys are the attribute names converted to symbols, and the
            # values the values of the attributes
            v.map{|a| Hash[a.keys.map{|k| [k.to_sym, a[k]]}]
            }
          ]
        }]
    end
      
    private :load_graphs, :load_fast, :load_classifications
  end
end

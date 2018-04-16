require "pp"
module Classifoclc
  class Work
    attr_reader :authors
    def initialize(node)
      @node = node
      @work = node.css('work').first
      @authors = node.css('author').
                 map{|a| Classifoclc::Author.new(a.text, a['lc'], a['viaf'])}
      @editions = nil
      @fetched_full = false
      @page = nil
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
      full unless @fetched_full

      Enumerator.new do |e|
        e << @editions

        loop do
          break if @next.nil?
          full(:startRec => @next)
          e << @editions
        end
      end
    end

    def full(hsh = {})
      params = {:identifier => 'owi', :value => owi,
                :summary => false}.merge(hsh)
      data = Classifoclc::fetch_data(params)
      @editions = data.css('edition').map{|e| Edition::new(e)}
      @fetched_full = true

      navigation = data.css("navigation")

      if navigation.empty?
        @next = nil
        @last = nil
      else
        n = data.css("navigation next").first
        l = data.css("navigation last").first

        if n.nil?
          @next = nil
        else
          @next = n.text.to_i
        end

        if l.nil?
          @last = nil
        else
          @last = l.text.to_i
        end
      end
      
    end


    private :full
  end
end

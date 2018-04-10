require "classifoclc/author.rb"
require "classifoclc/edition.rb"
require "classifoclc/errors.rb"
require "classifoclc/version"
require "classifoclc/work"
require "nokogiri"
require "open-uri"

module Classifoclc
  URI = "http://classify.oclc.org/classify2/Classify?%s=%s&summary=%s&maxRecs=%d"

  def self.lookup(hsh)

    max = hsh.fetch(:max, 25)
    summary = hsh.fetch(:summary, true)
    want_editions = hsh.fetch(:want_editions, false)

    resp = open(URI % [hsh[:identifier], hsh[:value], summary, max]).read

    parsed = Nokogiri::XML(resp)

    resp_code = parsed.css('response').first['code']

    if resp_code == '0' or resp_code == '2'
      if want_editions
        if resp_code == '0'
          return [Edition::new(parsed.css('work').first)]
        end
        return parsed.css('edition').map{|e| Edition::new(e)}
      end
      return [Work::new(parsed)]
    end

    if resp_code == '4'
      return parsed.css('work').map{|w| owi(w['owi'])}.flatten
    end

    if resp_code == '100'
      raise BadIdentifierError.
              new "%s is not allowed as an identifer" % hsh[:identifier]
    end

    if resp_code == '101'
      raise BadIdentifierFormatError.
              new "Invalid format (%s) for %s identifier" %
                  [hsh[:value], hsh[:identifier]]
    end

    if resp_code =='102'
      return []
    end

    if resp_code == '200'
      raise UnexpectedError.new "Unexpected error"
    end

    return parsed.css('work').map{|w| Work::new(w, parsed.css('author'))}
  end

  def self.isbn(isbn)
    lookup(:identifier => 'isbn', :value => isbn, :summary => true)
  end

  def self.owi(owi)
    lookup(:identifier => 'owi', :value  => owi, :summary => true)
  end

  def self.oclc(oclc)
    lookup(:identifier => 'oclc', :value  => oclc, :summary => true)
  end
  
end

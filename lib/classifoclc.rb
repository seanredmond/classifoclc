require "classifoclc/author.rb"
require "classifoclc/errors.rb"
require "classifoclc/version"
require "classifoclc/work"
require "nokogiri"
require "open-uri"

module Classifoclc
  URI = "http://classify.oclc.org/Classify?%s=%s&summary=true"

  def self.lookup(hsh)

    resp = open(URI % [hsh[:identifier], hsh[:value]]).read

    parsed = Nokogiri::XML(resp)


    resp_code = parsed.css('response').first['code']

    if resp_code == '0' or resp_code == '2'
      return [Work::new(parsed)]
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

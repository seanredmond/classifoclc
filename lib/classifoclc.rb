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

    unless parsed.css('input[type="noParam"]').empty?
      raise BadIdentifierError.
              new "%s is not allowed as an identifer" % hsh[:identifier]
    end

    return parsed.css('work').map{|w| Work::new(w)}
  end

  def self.isbn(isbn)
    lookup(:identifier => 'isbn', :value => isbn, :summary => true)
  end

  def self.owi(owi)
    lookup(:identifier => 'owi', :value  => owi, :summary => true)
  end
end

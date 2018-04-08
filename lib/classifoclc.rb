require "classifoclc/version"
require "classifoclc/work"
require "nokogiri"
require "open-uri"

module Classifoclc
  URI = "http://classify.oclc.org/Classify?%s=%s&summary=true"

  def self.lookup(hsh)

    resp = open(URI % [hsh[:identifier], hsh[:value]]).read

    parsed = Nokogiri::XML(resp)

    return parsed.css('work').map{|w| Work::new(w)}
  end

  def self.isbn(isbn)
    lookup(:identifier => 'isbn', :value => isbn, :summary => true)
  end

  def self.owi(owi)
    lookup(:identifier => 'owi', :value  => owi, :summary => true)
  end
end

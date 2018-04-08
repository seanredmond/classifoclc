require "classifoclc/version"
require "nokogiri"
require "open-uri"

module Classifoclc
  def self.Lookup(hsh)
    resp = open("http://classify.oclc.org/Classify?isbn=abc&summary=true").read
    parsed = Nokogiri::XML(resp)

    return parsed.css('work').map{|w| w}
  end
end

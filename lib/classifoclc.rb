require "classifoclc/version"
require "nokogiri"
require "open-uri"

module Classifoclc
  URI = "http://classify.oclc.org/Classify?isbn=%s&summary=true"

  def self.Lookup(hsh)

    unless hsh[:isbn].nil?
      resp = open(URI % hsh[:isbn]).read
    end

    parsed = Nokogiri::XML(resp)

    return parsed.css('work').map{|w| w}
  end
end

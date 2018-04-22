require "classifoclc/author.rb"
require "classifoclc/constants.rb"
require "classifoclc/edition.rb"
require "classifoclc/errors.rb"
require "classifoclc/recommendations"
require "classifoclc/version"
require "classifoclc/work"
require "nokogiri"
require "open-uri"
require "uri"

module Classifoclc
  @@maxRecs = 25

  def self.maxRecs
    @@maxRecs
  end

  def self.maxRecs= m
    @@maxRecs = m
  end
  
  def self.isbn(isbn, hsh = {})
    lookup(default_options(hsh, {:identifier => Id::ISBN, :value  => isbn}))
  end

  def self.owi(owi, hsh = {})
    lookup(default_options(hsh, {:identifier => Id::OWI, :value  => owi, :summary => false}))
  end

  def self.oclc(oclc, hsh = {})
    lookup(default_options(hsh, {:identifier => Id::OCLC, :value  => oclc}))
  end

  def self.lccn(lccn, hsh = {})
    lookup(default_options(hsh, {:identifier => Id::LCCN, :value  => lccn}))
  end

  def self.author(auth, hsh = {})
    lookup(default_options(hsh, {:identifier => Id::AUTHOR, :value  => auth}))
  end

  def self.title(title, hsh = {})
    lookup(default_options(hsh, {:identifier => Id::TITLE, :value  => title}))
  end

  def self.fast(ident, hsh = {})
    lookup(default_options(hsh, {:identifier => Id::IDENT, :value  => ident}))
  end
  
  private_class_method def self.lookup(hsh)
    parsed = fetch_data(hsh)
    resp_code = parsed.css('response').first['code']

    if resp_code == '0'
      owid = parsed.css('work').first['owi']
      return owi(owid)
    end

    if resp_code == '2'
      return Enumerator.new do |w|
        w << Work::new(parsed)
      end
    end

    if resp_code == "4"
      if hsh[:identifier] == :owi
        if parsed.css('work').map{|w| w['owi']}.include?(hsh[:value])
          raise Classifoclc::InfiniteLoopError.new("The record for owi %s contains records also with the owi %s. Cannot fetch data as it would lead to an infinite loop" % [hsh[:value], hsh[:value]])
        end
      end
      return multiwork(parsed, hsh)
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
      return Enumerator.new do |w|
      end
    end

    if resp_code == '200'
      raise UnexpectedError.new "Unexpected error"
    end
    
    raise UnexpectedError.new "Unexpected response code %s" % resp_code
  end

  private_class_method def self.multiwork(parsed, hsh)
    return Enumerator.new do |work|
      loop do
        if parsed.css("navigation next").empty?
          next_page = nil
        else
          next_page = parsed.css("navigation next").first.text
        end
        
        parsed.css('work').each do |multi|
          owi(multi['owi']).each do |w|
            work << w
          end
        end
        break if next_page.nil?
        parsed = fetch_data(hsh.clone.merge({:startRec => next_page}))
      end
    end
  end

  private_class_method def self.default_options(hsh1, hsh2 = {})
    {:orderby => OrderBy::HOLDINGS,
     :order => Order::DESC,
     :maxRecs => maxRecs,
     :summary => true}.merge(hsh1).merge(hsh2)
  end

  private_class_method def self.api_params(hsh)
    params = {:orderBy => "%s %s" % [hsh.delete(:orderby), hsh.delete(:order)]}.merge(hsh)
    return params
  end
  
  private_class_method def self.param_string(hsh)
    id = hsh.delete(:identifier)
    val = hsh.delete(:value)
    return api_params(default_options({id => val}, hsh))
             .map{|k,v| "#{k}=#{URI.encode_www_form_component(v)}"}.join("&") 
  end

  def self.fetch_data(hsh)
    resp = open(URL % param_string(hsh.clone)).read
    parsed = Nokogiri::XML(resp)
    return parsed
  end
end

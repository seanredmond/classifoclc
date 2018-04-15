require "classifoclc/author.rb"
require "classifoclc/constants.rb"
require "classifoclc/edition.rb"
require "classifoclc/errors.rb"
require "classifoclc/version"
require "classifoclc/work"
require "nokogiri"
require "open-uri"

module Classifoclc
  def self.isbn(isbn)
    lookup(:identifier => 'isbn', :value => isbn, :summary => true)
  end

  def self.owi(owi)
    lookup(:identifier => 'owi', :value  => owi, :summary => true)
  end

  def self.oclc(oclc, hsh = {})
    lookup(default_options(hsh, {:identifier => Id::OCLC, :value  => oclc}))
  end

  private_class_method def self.lookup(hsh)
    parsed = fetch_data(hsh)
    resp_code = parsed.css('response').first['code']

    if resp_code == '0' or resp_code == '2'
      return [Work::new(parsed)]
    end

    if resp_code == '4'
      if hsh[:identifier] == 'owi'
        if parsed.css('work').map{|w| w['owi']}.include?(hsh[:value])
          raise Classifoclc::InfiniteLoopError.new("The record for owi %s contains records also with the owi %s. Cannot fetch data as it would lead to an infinite loop" % [hsh[:value], hsh[:value]])
        end
      end
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

  private_class_method def self.default_options(hsh1, hsh2 = {})
    {:orderby => OrderBy::HOLDINGS,
     :order => Order::DESC,
     :maxRecs => 25,
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
             .map{|k,v| "#{k}=#{v}"}.join("&") 
  end

  def self.fetch_data(hsh)
    resp = open(URL % param_string(hsh.clone)).read
    parsed = Nokogiri::XML(resp)
    return parsed
  end
end

require "bundler/setup"
require "classifoclc"
require 'webmock/rspec'

SPEC_DIR = File.dirname(__FILE__)
RESP_DIR = File.join(SPEC_DIR, 'responses')
RESP_NONE = File.new(File.join(RESP_DIR, 'noresults.txt')).read
RESP_BADP = File.new(File.join(RESP_DIR, 'bad_param.txt')).read
RESP_BADF = File.new(File.join(RESP_DIR, 'bad_format.txt')).read
RESP_NOTF = File.new(File.join(RESP_DIR, 'not_found.txt')).read
RESP_UNEXPECTED = File.new(File.join(RESP_DIR, 'unexpected.txt')).read
RESP_MERIDIAN = File.new(File.join(RESP_DIR, '0151592659.txt')).read
RESP_MULT = File.new(File.join(RESP_DIR, 'multiple.txt')).read
RESP_MULTA = File.new(File.join(RESP_DIR, 'multiple-a.txt')).read
RESP_MULTB = File.new(File.join(RESP_DIR, 'multiple-b.txt')).read


RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each)  do
    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"isbn" => "abc", "summary" => "true"}).
      to_return(RESP_NONE)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"isbn" => "500error", "summary" => "true"}).
      to_return(status: 500)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"isbn" => "timeout", "summary" => "true"}).
      to_timeout

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"zzz" => "does not matter", "summary" => "true"}).
      to_return(RESP_BADP)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"isbn" => "0151592659zz", "summary" => "true"}).
      to_return(RESP_BADF)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"isbn" => "8765432109", "summary" => "true"}).
      to_return(RESP_NOTF)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"isbn" => "unexpected", "summary" => "true"}).
      to_return(RESP_UNEXPECTED)
    
    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"isbn" => "0151592659", "summary" => "true"}).
      to_return(RESP_MERIDIAN)

    stub_request(:get, "classify.oclc.org/Classify").
      with(query: {"oclc" => "2005960", "summary" => "true"}).
      to_return(RESP_MERIDIAN)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"isbn" => "0851775934", "summary" => "true"}).
      to_return(RESP_MULT)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"owi" => "4095816718", "summary" => "true"}).
      to_return(RESP_MULTA)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"owi" => "3375745328", "summary" => "true"}).
      to_return(RESP_MULTB)
  end
end


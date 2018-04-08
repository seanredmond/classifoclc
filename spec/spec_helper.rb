require "bundler/setup"
require "classifoclc"
require 'webmock/rspec'

SPEC_DIR = File.dirname(__FILE__)
RESP_DIR = File.join(SPEC_DIR, 'responses')
RESP_NONE = File.new(File.join(RESP_DIR, 'noresults.txt')).read
RESP_BADP = File.new(File.join(RESP_DIR, 'bad_param.txt')).read
RESP_MERIDIAN = File.new(File.join(RESP_DIR, '0151592659.txt')).read

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each)  do
    stub_request(:get, "classify.oclc.org/Classify").
      with(query: {"isbn" => "abc", "summary" => "true"}).
      to_return(RESP_NONE)

    stub_request(:get, "classify.oclc.org/Classify").
      with(query: {"isbn" => "500error", "summary" => "true"}).
      to_return(status: 500)

    stub_request(:get, "classify.oclc.org/Classify").
      with(query: {"isbn" => "timeout", "summary" => "true"}).
      to_timeout

    stub_request(:get, "classify.oclc.org/Classify").
      with(query: {"zzz" => "does not matter", "summary" => "true"}).
      to_return(RESP_BADP)

    stub_request(:get, "classify.oclc.org/Classify").
      with(query: {"isbn" => "0151592659", "summary" => "true"}).
      to_return(RESP_MERIDIAN)


  end

end


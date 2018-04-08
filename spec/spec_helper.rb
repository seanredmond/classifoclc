require "bundler/setup"
require "classifoclc"
require 'webmock/rspec'

SPEC_DIR = File.dirname(__FILE__)
RESP_DIR = File.join(SPEC_DIR, 'responses')
RESP_NONE = File.new(File.join(RESP_DIR, 'noresults.txt')).read

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
  end

end


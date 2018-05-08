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
RESP_UNHANDLED = File.new(File.join(RESP_DIR, 'unhandled.txt')).read
RESP_MERIDIAN = File.new(File.join(RESP_DIR, '0151592659.txt')).read
RESP_FULL = File.new(File.join(RESP_DIR, '0151592659-full.txt')).read
RESP_FULL2 = File.new(File.join(RESP_DIR, '0151592659-full-pg2.txt')).read
RESP_FULL3 = File.new(File.join(RESP_DIR, '0151592659-full-pg3.txt')).read
RESP_FULL4 = File.new(File.join(RESP_DIR, '0151592659-full-pg4.txt')).read
RESP_FULL5 = File.new(File.join(RESP_DIR, '0151592659-full-pg5.txt')).read
RESP_MULT = File.new(File.join(RESP_DIR, 'multiple.txt')).read
RESP_MULTA = File.new(File.join(RESP_DIR, 'multiple-a.txt')).read
RESP_MULTB = File.new(File.join(RESP_DIR, 'multiple-b.txt')).read
RESP_LOOP = File.new(File.join(RESP_DIR, '979229.txt')).read
RESP_HASLOOP = File.new(File.join(RESP_DIR, '0060205253.txt')).read
RESP_EXLEY1 = File.new(File.join(RESP_DIR, 'exley-pg1.txt')).read
RESP_EXLEY2 = File.new(File.join(RESP_DIR, 'exley-pg2.txt')).read
RESP_1665593 = File.new(File.join(RESP_DIR, 'owi1665593.txt')).read
RESP_462517 = File.new(File.join(RESP_DIR, 'owi462517.txt')).read
RESP_15394518 = File.new(File.join(RESP_DIR, 'owi15394518.txt')).read
RESP_2208251 = File.new(File.join(RESP_DIR, 'owi2208251.txt')).read
RESP_1358899616 = File.new(File.join(RESP_DIR, 'owi1358899616.txt')).read
RESP_867255897 = File.new(File.join(RESP_DIR, 'owi867255897.txt')).read
RESP_AUTH_TITLE = File.new(File.join(RESP_DIR, 'walker-meridian.txt')).read
RESP_28397104 = File.new(File.join(RESP_DIR, '28397104.txt')).read
RESP_454712380 = File.new(File.join(RESP_DIR, '454712380.txt')).read
RESP_413338 = File.new(File.join(RESP_DIR, '413338.txt')).read
RESP_4033902340 = File.new(File.join(RESP_DIR, '4033902340.txt')).read

UA = "Classifoclc/#{Classifoclc::VERSION}"

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
      with(query: {"isbn" => "abc", "summary" => "true", "maxRecs" => "25"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_NONE)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"isbn" => "500error", "summary" => "true",
                   "orderBy" => "hold desc", "maxRecs" => "25"},
           headers: {"User-Agent" => UA}).
      to_return(status: 500)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"isbn" => "timeout", "summary" => "true",
                   "orderBy" => "hold desc", "maxRecs" => "25"},
           headers: {"User-Agent" => UA}).
      to_timeout

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"zzz" => "does not matter", "summary" => "true",
                   "orderBy" => "hold desc", "maxRecs" => "25"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_BADP)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"isbn" => "0151592659zz", "summary" => "true",
                   "orderBy" => "hold desc", "maxRecs" => "25"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_BADF)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"isbn" => "8765432109", "summary" => "true",
                   "orderBy" => "hold desc", "maxRecs" => "25"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_NOTF)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"isbn" => "unexpected", "summary" => "true",
                   "orderBy" => "hold desc", "maxRecs" => "25"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_UNEXPECTED)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"isbn" => "unhandled", "summary" => "true",
                   "orderBy" => "hold desc", "maxRecs" => "25"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_UNHANDLED)
    
    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"isbn" => "0151592659", "summary" => "true",
                   "orderBy" => "hold desc", "maxRecs" => "25"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_MERIDIAN)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"oclc" => "2005960", "summary" => "true",
                   "maxRecs" => "25"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_MERIDIAN)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(
        query: {"owi" => "201096", "summary" => "false", "maxRecs" => "25",
                "orderBy" => "hold desc"},
        headers: {"User-Agent" => UA}
      ).to_return(RESP_FULL)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(
        query: {"owi" => "201096", "summary" => "false", "maxRecs" => "25",
                "orderBy" => "hold desc", "startRec" => "25"}
      ).to_return(RESP_FULL2)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(
        query: {"owi" => "201096", "summary" => "false", "maxRecs" => "25",
                "orderBy" => "hold desc", "startRec" => "50"},
        headers: {"User-Agent" => UA}
      ).to_return(RESP_FULL3)
    
    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(
        query: {"owi" => "201096", "summary" => "false", "maxRecs" => "25",
                "orderBy" => "hold desc", "startRec" => "75"},
        headers: {"User-Agent" => UA}
      ).to_return(RESP_FULL4)
    
    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(
        query: {"owi" => "201096", "summary" => "false", "maxRecs" => "25",
                "orderBy" => "hold desc", "startRec" => "100"},
        headers: {"User-Agent" => UA}
      ).to_return(RESP_FULL5)
    
    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"isbn" => "0851775934", "summary" => "true",
                   "orderBy" => "hold desc", "maxRecs" => "25"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_MULT)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"owi" => "4095816718", "summary" => "false",
                   "orderBy" => "hold desc", "maxRecs" => "25"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_MULTA)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"owi" => "3375745328", "summary" => "false",
                   "orderBy" => "hold desc", "maxRecs" => "25"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_MULTB)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"owi" => "979229", "summary" => "false",
                   "orderBy" => "hold desc", "maxRecs" => "25"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_LOOP)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"isbn" => "0060205253", "summary" => "true",
                   "orderBy" => "hold desc", "maxRecs" => "25"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_HASLOOP)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"author" => "Frederick Exley", "summary" => "true",
                   "orderBy" => "hold desc", "maxRecs" => "4"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_EXLEY1)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"author" => "Frederick Exley", "summary" => "true",
                   "orderBy" => "hold desc", "maxRecs" => "4",
                   "startRec" => "4"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_EXLEY2)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"owi" => "1665593", "summary" => "false",
                   "orderBy" => "hold desc", "maxRecs" => "4"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_1665593)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"owi" => "462517", "summary" => "false",
                   "orderBy" => "hold desc", "maxRecs" => "4"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_462517)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"owi" => "15394518", "summary" => "false",
                   "orderBy" => "hold desc", "maxRecs" => "4"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_15394518)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"owi" => "2208251", "summary" => "false",
                   "orderBy" => "hold desc", "maxRecs" => "4"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_2208251)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"owi" => "1358899616", "summary" => "false",
                   "orderBy" => "hold desc", "maxRecs" => "4"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_1358899616)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"owi" => "867255897", "summary" => "false",
                   "orderBy" => "hold desc", "maxRecs" => "4"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_867255897)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"author" => "Walker, Alice", "title" => "Meridian",
                   "summary" => "false", "orderBy" => "hold desc",
                   "maxRecs" => "25"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_AUTH_TITLE)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"owi" => "28397104", "summary" => "false",
                   "orderBy" => "hold desc", "maxRecs" => "25"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_28397104)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"owi" => "454712380", "summary" => "false",
                   "orderBy" => "hold desc", "maxRecs" => "25"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_454712380)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"owi" => "413338", "summary" => "false",
                   "orderBy" => "hold desc", "maxRecs" => "25"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_413338)

    stub_request(:get, "classify.oclc.org/classify2/Classify").
      with(query: {"owi" => "4033902340", "summary" => "false",
                   "orderBy" => "hold desc", "maxRecs" => "25"},
           headers: {"User-Agent" => UA}).
      to_return(RESP_4033902340)
  end
end


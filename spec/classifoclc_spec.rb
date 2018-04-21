require "pp"
RSpec.describe Classifoclc do
  
  it "has a version number" do
    expect(Classifoclc::VERSION).not_to be nil
  end

  describe "#maxRecs" do
    it "returns the default value" do
      expect(Classifoclc::maxRecs).to eq 25
    end

    it "can be changed", :maxrecs => true do
      expect(Classifoclc::maxRecs).to eq 25
      Classifoclc::maxRecs = 100
      expect(Classifoclc::maxRecs).to eq 100
      Classifoclc::maxRecs = 25
    end
  end
  
  describe "#lookup" do
    context "when there is trouble" do
      it "passes errors on up" do
        expect {works = Classifoclc::isbn('500error')}.
          to raise_error(OpenURI::HTTPError)
      end
    
      it "passes timeouts on up" do
        expect {works = Classifoclc::isbn('timeout')}.
          to raise_error Net::OpenTimeout
      end

      it "passes on unexpected error responses" do
        expect {works = Classifoclc::isbn('unexpected')}.
          to raise_error Classifoclc::UnexpectedError
      end

      it "raises an error on a response code we don't recognize" do
        expect {works = Classifoclc::isbn('unhandled')}.
          to raise_error Classifoclc::UnexpectedError
      end

      it "raises an error if there will be an infinite loop", :loop => true do
        works = Classifoclc::isbn('0060205253')
        expect { works.next }.
          to raise_error Classifoclc::InfiniteLoopError
      end
    end

    context "when you pass identifier with an invalid format" do
      it "raises a helpful error" do
        expect {works Classifoclc::isbn('0151592659zz')}.
          to raise_error Classifoclc::BadIdentifierFormatError
      end
    end
    
    context "when there is no record for the identifier" do
      it "returns an empty array" do
        works = Classifoclc::isbn('8765432109')
        expect(works).to be_a Enumerator
        expect(works.to_a).to be_empty
      end
    end

    context "when there is a record for the identifier" do
      it "returns an array" do
        works = Classifoclc::isbn('0151592659')
        expect(works).to be_a Enumerator
#        expect(works.count).to eq 1
        expect(works.next).to be_a Classifoclc::Work
      end
    end

    context "when there are multiple works", :multiple => true do
      it "returns an array of works" do
        works = Classifoclc::isbn('0851775934')

        expect(works).to be_a Enumerator
        expect(works.count).to eq 2
        expect(works.next).to be_a Classifoclc::Work
      end
    end
  end

  describe "#isbn" do
    it "calls #lookup with an ISBN" do
      expect(Classifoclc).
        to receive(:lookup).
             with({:identifier=>"isbn", :value=>"0151592659", :summary=>true})
      Classifoclc::isbn("0151592659")
    end
  end

  describe "#owi" do
    it "calls #lookup with an OWI", :owi => true do
      expect(Classifoclc).
        to receive(:lookup).
             with({:identifier => "owi", :value => "201096", :summary => false})
      Classifoclc::owi("201096")
    end
  end
  
  describe "#lccn" do
    it "calls #lookup with an LCCN" do
      expect(Classifoclc).
        to receive(:lookup).
             with({:identifier => Classifoclc::Id::LCCN, :value => "76000941",
                   :orderby => :hold, :order => :desc, :maxRecs => 25,
                   :summary => true})
      Classifoclc::lccn("76000941")
    end
  end
  
  describe "#oclc" do
    context "with default options" do 
      it "calls #lookup with an OCLC" do
        expect(Classifoclc).
          to receive(:lookup).
               with({:identifier => Classifoclc::Id::OCLC,
                     :value => "2005960",
                     :summary=>true,
                     :maxRecs => 25,
                     :orderby => Classifoclc::OrderBy::HOLDINGS,
                     :order => Classifoclc::Order::DESC})
        Classifoclc::oclc("2005960")
      end
    end

    context "with non-default options" do
      it "calls #lookup with the correct parameters" do
        expect(Classifoclc).
          to receive(:lookup).
               with({:identifier => Classifoclc::Id::OCLC,
                     :value => "2005960",
                     :summary => false,
                     :maxRecs => 25,
                     :orderby => Classifoclc::OrderBy::EDITIONS,
                     :order => Classifoclc::Order::DESC})
        Classifoclc::oclc("2005960", :summary => false,
                          :orderby => Classifoclc::OrderBy::EDITIONS,
                          :order => Classifoclc::Order::DESC)
      end
    end
  end

  describe "#author", :author => true do
    it "returns an Enumerator of works" do
      Classifoclc::maxRecs = 4
      works = Classifoclc::author("Frederick Exley")
      expect(works.to_a.count).to eq 6
      expect(works.to_a.first.owi).to eq "1358899616"
      expect(works.to_a.last.owi).to eq "867255897"
      Classifoclc::maxRecs = 25
    end
  end

  describe Classifoclc::Work do
    before(:each) do
      @meridian = Classifoclc::isbn("0151592659").first
    end

    it "has an owi" do
      expect(@meridian.owi).to eq "201096"
    end

    it "has a title" do
      expect(@meridian.title).to eq "Meridian"
    end

    it "has a format" do
      expect(@meridian.format).to eq "Book"
    end

    it "has an itemtype" do
      expect(@meridian.itemtype).to eq "itemtype-book"
    end

    it "has a count of editions" do
      expect(@meridian.edition_count).to be_a Integer
      expect(@meridian.edition_count).to eq 114
    end

    it "has a count of holdings" do
      expect(@meridian.holdings).to be_a Integer
      expect(@meridian.holdings).to eq 3264
    end
      
    it "has a count of eholdings" do
      expect(@meridian.eholdings).to be_a Integer
      expect(@meridian.eholdings).to eq 196
    end

    it "has authors" do
      expect(@meridian.authors).to be_a Array
    end

    it "has editions", :editions => true do
      eds = @meridian.editions.next
      expect(eds).to be_a Classifoclc::Edition
    end

    it "can have multiple pages of editions" do
      eds = @meridian.editions

      # Check the expected OCLC number of the first edition on each
      # page of 25 results
      expect(eds.next.oclc).to eq "2005960"
      24.times do eds.next end # rest of page 1. Next call loads next page
      expect(eds.next.oclc).to eq "68252283"
      24.times do eds.next end # rest of page 2
      expect(eds.next.oclc).to eq "21737153"
      24.times do eds.next end # rest of page 3
      expect(eds.next.oclc).to eq "953165537"
      24.times do eds.next end # rest of page 4
      expect(eds.next.oclc).to eq "17757474"
      13.times do eds.next end # rest of page 5
      expect{eds.next.oclc}.to raise_error(StopIteration)
    end

    it "can return all the editions" do
      eds = @meridian.editions
      expect(eds.map{|e| e}.flatten.count).to eq 114
    end

    it "has recommendations", :recommendations => true do
      expect(@meridian.recommendations).to be_a Classifoclc::Recommendations
    end
  end

  describe Classifoclc::Author do
    before(:each) do
      @author = Classifoclc::isbn("0151592659").first.authors.first
    end

    it "has a name" do
      expect(@author.name).to eq "Walker, Alice, 1944-"
    end

    it "has an LC identifier" do
      expect(@author.lc).to eq "n79109131"
    end

    it "has a VIAF identifier"  do
      expect(@author.viaf).to eq "108495772"
    end
  end

  describe Classifoclc::Edition do
    before(:each) do
      @meridian = Classifoclc::isbn("0151592659").first
      @editions = @meridian.editions
      @ed = @editions.next
    end

    it "has an OCLC number" do
      expect(@ed.oclc).to eq "2005960"
    end

    it "has authors" do
      expect(@ed.authors).to eq "Walker, Alice, 1944-"
    end

    it "has a title" do
      expect(@ed.title).to eq "Meridian"
    end

    it "has a format" do
      expect(@ed.format).to eq "Book"
    end

    it "has an itemtype" do
      expect(@ed.itemtype).to eq "itemtype-book"
    end

    it "has holdings" do
      expect(@ed.holdings).to eq 1420
    end

    it "has eholdings" do
      expect(@ed.eholdings).to eq 0
    end

    it "has a language" do
      expect(@ed.language).to eq "eng"
    end

    describe "#classifications" do
      it "it returns an Array" do
        expect(@ed.classifications).to be_a Array
      end

      it "is an Array of Hashes" do
        expect(@ed.classifications.first).to be_a Hash
        expect(@ed.classifications.first[:sfa]).to eq "813.54"
      end
    end
  end

  describe Classifoclc::Recommendations, :recommendations => true do
    before(:each) do
      @meridian = Classifoclc::isbn("0151592659").first.recommendations
    end

    describe "#graphs" do
      it "returns an hash of URLs" do
        expect(@meridian.graphs).to be_a Hash
        expect(@meridian.graphs[:all]).to eq "http://chart.apis.google.com/chart?cht=p&chd=e:9bCk&chs=350x200&chts=000000,16&chtt=All+Editions&chco=0D0399,124DBA&chdl=Classified|Unclassified"
      end
    end

    describe "#fast" do
      it "returns an array of hashes" do
        expect(@meridian.fast).to be_a Array
        expect(@meridian.fast.first[:heading]).to eq "Southern States"
      end
    end

    describe "#ddc" do
      it "returns Dewey Decimal classifications" do
        expect(@meridian.ddc).to be_a Hash
        expect(@meridian.ddc[:mostPopular]).to be_a Array
        expect(@meridian.ddc[:mostPopular].first[:nsfa]).to eq "813.54"
      end
    end

    describe "#lcc" do
      it "returns Library of Congress classifications" do
        expect(@meridian.lcc).to be_a Hash
        expect(@meridian.lcc[:mostPopular]).to be_a Array
        expect(@meridian.lcc[:mostPopular].first[:nsfa]).to eq "PS3573.A425"
      end
    end
  end
end

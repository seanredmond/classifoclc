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

      it "raises an error if there will be an infinite loop", :loop => true do
        expect { works = Classifoclc::isbn('0060205253') }.
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
        expect(works).to be_a Array
        expect(works).to be_empty
      end
    end

    context "when there is a record for the identifier" do
      it "returns an array" do
        works = Classifoclc::isbn('0151592659')
        expect(works).to be_a Array
        expect(works.count).to eq 1
        expect(works.first).to be_a Classifoclc::Work
      end
    end

    context "when there are multiple works" do
      it "returns an array of works" do
        works = Classifoclc::isbn('0851775934')

        expect(works).to be_a Array
        expect(works.count).to eq 2
        expect(works[0]).to be_a Classifoclc::Work
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
    it "calls #lookup with an OWI" do
      expect(Classifoclc).
        to receive(:lookup).
             with({:identifier=>"owi", :value=>"201096", :summary=>true})
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
      expect(eds).to be_a Array
      expect(eds.count).to eq 25
      expect(eds.first).to be_a Classifoclc::Edition
    end

    it "can have multiple pages of editions" do
      eds = @meridian.editions
      expect(eds.next.first.oclc).to eq "2005960"
      expect(eds.next.first.oclc).to eq "68252283"
      expect(eds.next.first.oclc).to eq "21737153"
      expect(eds.next.first.oclc).to eq "953165537"
      expect(eds.next.first.oclc).to eq "17757474"
      expect{eds.next.first.oclc}.to raise_error(StopIteration)
    end

    it "can return all the editions" do
      eds = @meridian.editions
      expect(eds.map{|e| e}.flatten.count).to eq 114
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
      @editions = @meridian.editions.next
      @ed = @editions.first
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
  end
end

RSpec.describe Classifoclc do
  
  it "has a version number" do
    expect(Classifoclc::VERSION).not_to be nil
  end

  describe "#lookup" do
    context "when their is trouble" do
      it "passes errors on up" do
        expect {works = Classifoclc::lookup(:identifier => 'isbn',
                                            :value => '500error')}.
          to raise_error(OpenURI::HTTPError)
      end
    
      it "passes timeouts on up" do
        expect {works = Classifoclc::lookup(:identifier => 'isbn',
                                            :value => 'timeout')}.
          to raise_error Net::OpenTimeout
      end
    end

    context "when you pass a bad identifier" do
      it "raises a helpful error" do
        expect {works Classifoclc::lookup(:identifier => 'zzz',
                                          :value => 'does not matter')}.
          to raise_error Classifoclc::BadIdentifierError
      end
    end
    
    context "when there is no record for the identifier" do
      it "returns an empty array" do
        works = Classifoclc::lookup(:identifier => 'isbn', :value => 'abc')
        expect(works).to be_a Array
        expect(works).to be_empty
      end
    end

    context "when there is a record for the identifier" do
      it "returns an empty array" do
        works = Classifoclc::lookup(:identifier => 'isbn',
                                    :value => '0151592659')
        expect(works).to be_a Array
        expect(works.count).to eq 1
        expect(works.first).to be_a Classifoclc::Work
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
  
  describe "#oclc" do
    it "calls #lookup with an OCLC" do
      expect(Classifoclc).
        to receive(:lookup).
             with({:identifier=>"oclc", :value=>"2005960", :summary=>true})
      Classifoclc::oclc("2005960")
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
      expect(@meridian.editions).to be_a Integer
      expect(@meridian.editions).to eq 114
    end

    it "has a count of holdings" do
      expect(@meridian.holdings).to be_a Integer
      expect(@meridian.holdings).to eq 3264
    end
      
    it "has a count of eholdings" do
      expect(@meridian.eholdings).to be_a Integer
      expect(@meridian.eholdings).to eq 196
    end
  end
end

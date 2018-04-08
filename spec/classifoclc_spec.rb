RSpec.describe Classifoclc do
  
  it "has a version number" do
    expect(Classifoclc::VERSION).not_to be nil
  end

  describe "#lookup" do
    context "when their is trouble" do
      it "passes errors on up" do
        expect {works = Classifoclc::lookup :isbn => '500error'}.
          to raise_error(OpenURI::HTTPError)
      end
    
      it "passes timeouts on up" do
        expect {works = Classifoclc::lookup :isbn => 'timeout'}.
          to raise_error Net::OpenTimeout
      end
    end
    
    context "when the identifier is no good" do
      it "returns an empty array" do
        works = Classifoclc::lookup :isbn => 'abc'
        expect(works).to be_a Array
        expect(works).to be_empty
      end
    end

    context "when the identifier is good" do
      it "returns an empty array" do
        works = Classifoclc::lookup :isbn => '0151592659'
        expect(works).to be_a Array
        expect(works.count).to eq 1
        expect(works.first).to be_a Classifoclc::Work
      end
    end
  end

  describe "#isbn" do
    it "calls #lookup with an ISBN" do
      expect(Classifoclc).
        to receive(:lookup).with({:isbn=>"0151592659", :summary=>true})
      Classifoclc::isbn('0151592659')
    end
  end
  
end

RSpec.describe Classifoclc do
  
  it "has a version number" do
    expect(Classifoclc::VERSION).not_to be nil
  end

  describe "#Lookup" do
    context "when their is trouble" do
      it "passes errors on up" do
        expect {works = Classifoclc::Lookup :isbn => '500error'}.
          to raise_error(OpenURI::HTTPError)
      end
    
      it "passes timeouts on up" do
        expect {works = Classifoclc::Lookup :isbn => 'timeout'}.
          to raise_error Net::OpenTimeout
      end
    end
    
    context "when the identifier is no good" do
      it "returns an empty array" do
        works = Classifoclc::Lookup :isbn => 'abc'
        expect(works).to be_a Array
        expect(works).to be_empty
      end
    end
  end
end

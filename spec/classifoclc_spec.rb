RSpec.describe Classifoclc do
  
  it "has a version number" do
    expect(Classifoclc::VERSION).not_to be nil
  end

  describe "#Lookup" do
    context "when the identifier is no good" do
      it "returns an empty array" do
        works = Classifoclc::Lookup :isbn => 'abc'
        expect(works).to be_a Array
        expect(works).to be_empty
      end
    end
  end
end

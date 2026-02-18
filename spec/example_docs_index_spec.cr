require "spec"
require "../src/examples"

describe Examples do
  it "requires metadata annotations for each registered applet" do
    Examples.validate_docs_metadata!
  end

  it "exposes macro-collected docs entries" do
    Examples.docs_entries.empty?.should be_false
  end
end

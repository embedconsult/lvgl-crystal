require "spec"
require "../src/examples"

describe Examples do
  it "requires metadata annotations for each registered applet" do
    Examples.validate_docs_metadata!
  end

  it "exposes macro-collected docs entries" do
    Examples.docs_entries.empty?.should be_false
  end

  it "exposes a browseable docs gallery entry list" do
    Examples::DocsGallery.entries.should eq(Examples.docs_entries)
  end

  it "ensures each example source comment links to a LVGL upstream example" do
    source_files = Dir.glob(File.join(__DIR__, "..", "src", "examples", "**", "*.cr"))

    Examples.docs_entries.each do |entry|
      basename = File.basename(entry.image_path, ".png")
      source_file = source_files.find { |path| File.basename(path, ".cr") == basename }
      source_file.should_not be_nil
      next unless source_file

      content = File.read(source_file)
      content.includes?("# [Source](#{entry.source_url})").should be_true
    end
  end
end

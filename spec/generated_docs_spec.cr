require "spec"
require "file_utils"

record LinkCheckResult,
  url : String,
  error : String,
  network_limited : Bool

def build_docs!(output_dir : String) : Nil
  docs_out = IO::Memory.new
  docs_err = IO::Memory.new

  status = Process.run(
    "crystal",
    ["docs", "-o", output_dir],
    output: docs_out,
    error: docs_err
  )

  status.success?.should be_true, "\n#{docs_out}#{docs_err}"
end

def generated_doc_urls(output_dir : String) : Array(String)
  urls = [] of String
  html_files = Dir.glob(File.join(output_dir, "**", "*.html"))

  html_files.each do |file|
    content = File.read(file)

    content.scan(%r{https?://[^\s"'<>)]+}) do |match_data|
      urls << match_data[0]
    end
  end

  normalized_urls = urls
    .map(&.gsub(/#.*\z/, ""))
    .map(&.gsub(/[\.,;:]+\z/, ""))

  normalized_urls.uniq!.sort!
end

def curl_check(url : String, use_head : Bool) : Tuple(Bool, String)
  output = IO::Memory.new
  error_output = IO::Memory.new
  args = ["-fsS", "--max-time", "15", "--connect-timeout", "5"]
  args << "-I" if use_head
  args << url

  status = Process.run("curl", args, output: output, error: error_output)
  {status.success?, "#{output}#{error_output}"}
end

def check_url(url : String) : LinkCheckResult?
  success, details = curl_check(url, use_head: true)
  unless success
    success, details = curl_check(url, use_head: false)
  end

  return nil if success

  network_limited = details.includes?("Could not resolve host") ||
                    details.includes?("Failed to connect") ||
                    details.includes?("Connection timed out") ||
                    details.includes?("Operation timed out") ||
                    details.includes?("Network is unreachable")

  LinkCheckResult.new(url: url, error: details.presence || "curl failed", network_limited: network_limited)
end

def with_tmp_docs_dir(&)
  tmpdir = File.join(Dir.tempdir, "lvgl-crystal-docs-#{Random.rand(1_000_000_000)}")
  Dir.mkdir_p(tmpdir)

  begin
    yield tmpdir
  ensure
    FileUtils.rm_rf(tmpdir)
  end
end

describe "generated API docs" do
  it "builds docs successfully" do
    with_tmp_docs_dir do |tmpdir|
      build_docs!(tmpdir)
      File.exists?(File.join(tmpdir, "index.html")).should be_true
      File.exists?(File.join(tmpdir, "Examples", "DocsGallery.html")).should be_true
    end
  end

  it "has fetchable external links in generated docs" do
    with_tmp_docs_dir do |tmpdir|
      build_docs!(tmpdir)

      links = generated_doc_urls(tmpdir)
      links.empty?.should be_false

      failures = links.compact_map { |url| check_url(url) }
      next if failures.empty?

      well_known_prefixes = [
        "https://docs.lvgl.io/9.4/",
        "https://docs.lvgl.io/master/",
        "https://github.com/embedconsult/lvgl-crystal",
        "https://crystal-lang.org/reference/",
        "http://www.w3.org/2000/svg",
      ]

      unknown_failures = failures.reject do |failure|
        well_known_match = well_known_prefixes.any? { |prefix| failure.url.starts_with?(prefix) }
        limited_access = failure.network_limited || failure.error.includes?("HTTP 403") || failure.error.includes?("returned error: 403")
        well_known_match && limited_access
      end

      if unknown_failures.empty?
        pending_messages = failures.map { |failure| "- #{failure.url}: #{failure.error}" }.join("\n")
        pending!("Unable to fetch well-known docs links in this environment:\n#{pending_messages}")
      else
        details = unknown_failures.map { |failure| "- #{failure.url}: #{failure.error}" }.join("\n")
        fail("Broken external links found in generated docs:\n#{details}")
      end
    end
  end
end

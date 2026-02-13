require "spec"

describe "public docs checker" do
  it "finds comments for every pubic method" do
    output = IO::Memory.new
    error_output = IO::Memory.new

    status = Process.run(
      "crystal",
      ["run", "scripts/check_public_docs.cr"],
      output: output,
      error: error_output
    )

    status.success?.should be_true, "\n#{output}#{error_output}"
  end
end

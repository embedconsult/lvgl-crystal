require "spec"

describe "public method spec coverage" do
  it "requires every public method to be spec-referenced or exempted" do
    output = IO::Memory.new
    error_output = IO::Memory.new

    status = Process.run(
      "crystal",
      ["run", "scripts/check_public_method_spec_coverage.cr"],
      output: output,
      error: error_output
    )

    status.success?.should be_true, "\n#{output}#{error_output}"
  end
end

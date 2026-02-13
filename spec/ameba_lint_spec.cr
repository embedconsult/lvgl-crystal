require "spec"

describe "ameba Crystal linter" do
  it "finds no issues with the source" do
    output = IO::Memory.new
    error_output = IO::Memory.new

    status = Process.run(
      "bin/ameba",
      output: output,
      error: error_output
    )

    status.success?.should be_true, "\n#{output}#{error_output}"
  end
end

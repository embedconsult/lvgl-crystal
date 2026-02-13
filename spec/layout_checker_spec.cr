require "spec"

describe "layout checker" do
  it "finds files in the occasional strange place" do
    output = IO::Memory.new
    error_output = IO::Memory.new

    status = Process.run(
      "crystal",
      ["run", "scripts/check_structure_layout.cr"],
      output: output,
      error: error_output
    )

    status.success?.should be_true, "\n#{output}#{error_output}"
  end
end

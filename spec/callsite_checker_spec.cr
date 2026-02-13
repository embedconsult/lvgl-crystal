require "spec"

describe "LibLvgl direct callsite checker" do
  it "has no duplicate non-allowlisted direct LibLvgl callsites in src" do
    output = IO::Memory.new
    error_output = IO::Memory.new

    status = Process.run(
      "crystal",
      ["run", "scripts/check_lvgl_callsites.cr"],
      output: output,
      error: error_output
    )

    status.success?.should be_true, "\n#{output}#{error_output}"
  end
end

#!/usr/bin/env crystal

module StructureLayoutCheck
  EXAMPLE_GLOB = "src/examples/**/*.cr"
  SOURCE_GLOB  = "src/**/*.cr"
  SPEC_GLOB    = "spec/**/*_spec.cr"

  def self.run : Int32
    errors = [] of String

    errors.concat(example_layout_errors)
    errors.concat(wrapper_location_errors)
    errors.concat(spec_mirror_errors)

    if errors.empty?
      puts "Repository structure checks passed."
      return 0
    end

    STDERR.puts "Repository structure checks failed:"
    errors.each { |error| STDERR.puts "- #{error}" }
    1
  end

  private def self.example_layout_errors : Array(String)
    errors = [] of String

    Dir.glob(EXAMPLE_GLOB).sort.each do |path|
      relative = path.sub(%r{\Asrc/examples/}, "")
      segments = relative.split('/')

      if segments.size < 2
        errors << "Example source must be under src/examples/<topic>/: #{path}"
      end
    end

    errors
  end

  private def self.wrapper_location_errors : Array(String)
    errors = [] of String

    Dir.glob(SOURCE_GLOB).sort.each do |path|
      next if path.starts_with?("src/lvgl/")

      File.read_lines(path).each_with_index(1) do |line, line_number|
        next unless line.includes?("LibLvgl.lv_")

        errors << "Direct LibLvgl wrapper call outside src/lvgl/: #{path}:#{line_number}"
      end
    end

    errors
  end

  private def self.spec_mirror_errors : Array(String)
    errors = [] of String

    Dir.glob(SPEC_GLOB).sort.each do |spec_path|
      next unless spec_path.starts_with?("spec/lvgl") || spec_path.starts_with?("spec/examples")

      source_path = mirrored_source_path(spec_path)
      next if File.exists?(source_path)

      errors << "Spec path should mirror source structure: #{spec_path} (expected #{source_path})"
    end

    errors
  end

  private def self.mirrored_source_path(spec_path : String) : String
    relative = spec_path.sub(%r{\Aspec/}, "")
    "src/#{relative.sub(/_spec\.cr\z/, ".cr")}"
  end
end

exit StructureLayoutCheck.run

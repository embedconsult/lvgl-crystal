#!/usr/bin/env crystal

require "set"

struct PublicMethod
  getter key : String
  getter name : String
  getter file : String
  getter line : Int32

  def initialize(@key : String, @name : String, @file : String, @line : Int32)
  end
end

module PublicMethodCoverage
  SRC_PATTERNS    = ["src/lvgl.cr", "src/lvgl/**/*.cr"]
  SPEC_PATTERN    = "spec/**/*.cr"
  EXEMPTIONS_PATH = "spec/public_method_coverage_exemptions.txt"

  def self.run : Int32
    methods = extract_public_methods
    spec_sources = load_spec_sources
    exemptions = load_exemptions

    covered = methods.select { |method| referenced_in_specs?(method, spec_sources) }
    exempted = methods.select { |method| exemptions.includes?(method.key) }
    uncovered = methods.reject { |method| covered.includes?(method) || exempted.includes?(method) }

    puts "Public method spec coverage report"
    puts "- Total public methods: #{methods.size}"
    puts "- Covered by specs:    #{covered.size}"
    puts "- Exemptions:          #{exempted.size}"
    puts "- Uncovered:           #{uncovered.size}"

    unless uncovered.empty?
      puts "\nUncovered public methods (require spec or exemption):"
      uncovered.each do |method|
        puts "- #{method.key} (#{method.file}:#{method.line})"
      end
    end

    stale = exemptions.reject { |entry| methods.any? { |method| method.key == entry } }
    unless stale.empty?
      puts "\nStale exemptions (consider removing):"
      stale.sort.each { |entry| puts "- #{entry}" }
    end

    uncovered.empty? ? 0 : 1
  end

  private def self.extract_public_methods : Array(PublicMethod)
    methods = [] of PublicMethod

    SRC_PATTERNS.each do |pattern|
      Dir.glob(pattern).sort.each do |path|
        methods.concat(extract_public_methods_from_file(path))
      end
    end

    methods
  end

  private def self.extract_public_methods_from_file(path : String) : Array(PublicMethod)
    methods = [] of PublicMethod
    visibility = "public"

    File.read_lines(path).each_with_index(1) do |line, line_number|
      stripped = line.strip
      next if stripped.empty? || stripped.starts_with?("#")

      if visibility_match = stripped.match(/\A(private|protected|public)\z/)
        visibility = visibility_match[1]
        next
      end

      if def_match = stripped.match(/\A(?:(private|protected|public)\s+)?def\s+([^\s\(\:]+)/)
        def_visibility = def_match[1]? || visibility
        next unless def_visibility == "public"

        method_name = def_match[2]
        key = "#{path}##{method_name}"
        methods << PublicMethod.new(key, method_name, path, line_number)
      end
    end

    methods
  end

  private def self.load_spec_sources : String
    contents = String.build do |io|
      Dir.glob(SPEC_PATTERN).sort.each do |path|
        io << File.read(path)
        io << "\n"
      end
    end

    contents
  end

  private def self.referenced_in_specs?(method : PublicMethod, spec_sources : String) : Bool
    name = method.name
    bare = name.starts_with?("self.") ? name.lchop("self.") : name

    reference_patterns = [
      reference_pattern(name),
      reference_pattern(bare),
      /\.#{Regex.escape(bare)}/,
    ]

    reference_patterns.any? { |pattern| spec_sources.matches?(pattern) }
  end

  private def self.reference_pattern(name : String) : Regex
    /(?<![A-Za-z0-9_])#{Regex.escape(name)}(?![A-Za-z0-9_])/
  end

  private def self.load_exemptions : Set(String)
    exemptions = Set(String).new
    return exemptions unless File.exists?(EXEMPTIONS_PATH)

    File.read_lines(EXEMPTIONS_PATH).each do |line|
      entry = line.strip
      next if entry.empty? || entry.starts_with?("#")

      key = entry.split("|", 2).first.strip
      exemptions << key unless key.empty?
    end

    exemptions
  end
end

exit PublicMethodCoverage.run

#!/usr/bin/env crystal

record Duplicate, symbol : String, locations : Array(String)

CALLSITE_REGEX = /(?<!["'])\bLibLvgl\.lv_[A-Za-z0-9_]+\b/

project_root = File.expand_path("..", __DIR__)
source_root = File.join(project_root, "src")
allowlist_file = File.join(project_root, "scripts", "lvgl_callsites_allowlist.txt")

allowlist = Set(String).new
if File.exists?(allowlist_file)
  File.each_line(allowlist_file) do |line|
    symbol = line.sub(/#.*$/, "").strip
    next if symbol.empty?
    allowlist << symbol
  end
end

callsites = Hash(String, Array(String)).new { |hash, key| hash[key] = [] of String }

Dir.glob(File.join(source_root, "**", "*.cr")).sort!.each do |path|
  File.read_lines(path).each_with_index(1) do |line, line_number|
    line.scan(CALLSITE_REGEX) do |match_data|
      symbol = match_data[0]
      callsites[symbol] << "#{path}:#{line_number}"
    end
  end
end

duplicates = callsites
  .compact_map do |symbol, locations|
    next if locations.size <= 1
    next if allowlist.includes?(symbol)

    Duplicate.new(symbol: symbol, locations: locations)
  end
  .sort_by!(&.symbol)

if duplicates.empty?
  puts "No duplicate non-allowlisted LibLvgl callsites found in src/."
  exit 0
end

duplicates.each do |entry|
  STDERR.puts "Duplicate direct callsites for #{entry.symbol} (#{entry.locations.size} occurrences):"
  entry.locations.each do |location|
    STDERR.puts "  - #{location}"
  end
  STDERR.puts
end

STDERR.puts "Found duplicate direct LibLvgl callsites."
STDERR.puts "Create/reuse a canonical wrapper method for each symbol, or add an explicit"
STDERR.puts "exception to scripts/lvgl_callsites_allowlist.txt."
exit 1

#!/usr/bin/env crystal

require "log"

files = Dir.glob("src/**/*.cr")
errors = [] of String

def ignorable_doc_barrier?(line : String) : Bool
  stripped = line.lstrip
  stripped.starts_with?("@[") ||
    stripped.starts_with?("{%") ||
    stripped.starts_with?("{{")
end

files.each do |file|
  Log.debug { "Checking #{file}" }
  lines = File.read_lines(file)

  lines.each_with_index do |line, idx|
    stripped = line.lstrip
    next unless stripped.starts_with?("# Source:")

    unless stripped.includes?("[") && stripped.includes?("](")
      errors << "#{file}:#{idx + 1} Source reference must use a Markdown link"
    end
  end

  lines.each_with_index do |line, idx|
    stripped = line.lstrip

    declaration = stripped.match(/^(class|module|struct|enum)\s+([A-Z][\w:]*)/)
    method = stripped.match(/^def\s+(?:self\.)?([a-zA-Z_\[\]=][\w!?=\[\]]*)/)

    next unless declaration || method
    next if stripped.starts_with?("private ") || stripped.starts_with?("protected ")

    if declaration.nil?
      if method.nil?
        name = nil
      else
        name = method[1]
      end
    else
      name = declaration[2]
    end
    next if name == "initialize"
    next if declaration && !name.nil? && name.includes?("::")

    has_doc = false
    j = idx - 1
    while j >= 0
      prev = lines[j]
      if prev.strip.empty?
        j -= 1
        next
      end
      if ignorable_doc_barrier?(prev)
        j -= 1
        next
      end
      if prev.lstrip.starts_with?("#")
        has_doc = true
        j -= 1
        next
      end
      break
    end

    unless has_doc
      errors << "#{file}:#{idx + 1} missing docs for #{name}"
    end
  end
end

if errors.empty?
  Log.info { "Documentation check passed" }
  exit 0
end

errors.each { |error| puts error }
exit 1

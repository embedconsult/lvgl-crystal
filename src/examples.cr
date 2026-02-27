require "log"
require "./examples/**"

# An applet is an easy way to build an LVGL application in Crystal.
#
# Each example is written as an applet. To make an applet, define your application
# as a class that inherits `Lvgl::Applet`.
#
# To invoke an application from the command-line:
#
# ```bash
# crystal run src/examples.cr
# ```
#
# Replace `src/examples.cr` with the particular example you'd like to run.
#
# ### Background summary:
# * [Original C examples](https://docs.lvgl.io/9.4/examples.html)
# * Every local example must map 1-to-1 to a single LVGL upstream example URL.
# * Each example inherits the `Lvgl::Applet` class to simplify integration.
# * Each example implements the `setup`, `loop`, and `cleanup` methods if appropriate.
# * The lifecyle is managed by `Lvgl.main`.
# * The backend can be set with the LVGL_BACKEND environment variable.
# * The `liblvgl.so` library is linked dynamically and available backends are configured at run-time.
#
# ### Example gallery
#
# Browse all documented examples from one page in Crystal docs via
# `Examples::DocsGallery`.
#
class Examples < Lvgl::Applet
  # Canonical metadata record collected from @[Lvgl::ExampleMetadata(...)] annotations.
  record DocsEntry,
    applet_class : Lvgl::Applet.class,
    class_name : String,
    section : String,
    title : String,
    summary : String,
    image_path : String,
    source_url : String do
    # Absolute output location used by image generation scripts.
    def docs_output_path : String
      File.join("docs", image_path)
    end
  end

  # Compile-time list of all annotated example applets.
  DOCS_ENTRIES = begin
    entries = [] of DocsEntry

    {% for subclass in Lvgl::Applet.all_subclasses %}
      {% metadata = subclass.annotation(Lvgl::ExampleMetadata) %}
      {% if metadata %}
        entries << DocsEntry.new(
          applet_class: {{ subclass }},
          class_name: {{ subclass.name.stringify }},
          section: {{ metadata[:section] }},
          title: {{ metadata[:title] }},
          summary: {{ metadata[:summary] }},
          image_path: {{ metadata[:image_path] }},
          source_url: {{ metadata[:source_url] }}
        )
      {% end %}
    {% end %}

    entries
  end

  # Returns metadata entries for all annotated applets.
  def self.docs_entries : Array(DocsEntry)
    DOCS_ENTRIES
  end

  # Browseable Crystal-docs gallery of examples, inspired by LVGL's upstream
  # examples index page.
  module DocsGallery
    # API-docs overview with image-backed entries.
    #
    # Each generated method below acts like a gallery card:
    #
    # 1. Section + title for scanability.
    # 2. Summary paragraph to explain what the screenshot demonstrates.
    # 3. Inline screenshot rendered by Crystal docs markdown support.
    # 4. Upstream LVGL source link for parity checks.
    #
    # This layout is intentionally simple because `crystal docs` HTML structure
    # is template-driven and not theme-extensible from this repository.
    # Returns the same metadata used for docs generation and consistency checks.
    def self.entries : Array(Examples::DocsEntry)
      Examples.docs_entries
    end

    {% for subclass in Lvgl::Applet.all_subclasses %}
      {% metadata = subclass.annotation(Lvgl::ExampleMetadata) %}
      {% if metadata %}
        # {{ metadata[:section].id }}: {{ metadata[:title].id }}
        #
        # `{{ subclass.name }}`
        #
        # {{ metadata[:summary].id }}
        #
        # ![{{ subclass.name }}]({{ metadata[:image_path].id }})
        #
        # [Source]({{ metadata[:source_url].id }})
        def self.{{("example_" + subclass.name.stringify.underscore).id}} : Nil
        end
      {% end %}
    {% end %}
  end

  # Ensures every registered applet (except this aggregate runner) is annotated
  # and that there are no stale metadata entries.
  def self.validate_docs_metadata! : Nil
    docs_root = "https://docs.lvgl.io/9.4/examples.html#"
    documented_names = docs_entries.map(&.class_name)
    source_urls = docs_entries.map(&.source_url)
    registered_names = Lvgl::Applet.registry.map(&.new.class_name).reject { |name| name == "Examples" }

    missing_metadata = registered_names.reject { |name| documented_names.includes?(name) }
    stale_metadata = documented_names.reject { |name| registered_names.includes?(name) }
    invalid_source_urls = docs_entries.select { |entry| !entry.source_url.starts_with?(docs_root) }
    duplicate_source_urls = source_urls.group_by { |url| url }.select { |_, urls| urls.size > 1 }.keys

    return if missing_metadata.empty? && stale_metadata.empty? && invalid_source_urls.empty? && duplicate_source_urls.empty?

    STDERR.puts "Example metadata mismatch detected:"
    unless missing_metadata.empty?
      STDERR.puts "- Applets missing @[Lvgl::ExampleMetadata(...)] annotation:"
      missing_metadata.sort.each { |name| STDERR.puts "  - #{name}" }
    end

    unless stale_metadata.empty?
      STDERR.puts "- Metadata entries without registered applets:"
      stale_metadata.sort.each { |name| STDERR.puts "  - #{name}" }
    end

    unless invalid_source_urls.empty?
      STDERR.puts "- Applets with source_url outside #{docs_root}*:"
      invalid_source_urls.sort_by(&.class_name).each do |entry|
        STDERR.puts "  - #{entry.class_name}: #{entry.source_url}"
      end
    end

    unless duplicate_source_urls.empty?
      STDERR.puts "- Duplicate source_url mappings (examples must be 1-to-1):"
      duplicate_source_urls.sort.each { |url| STDERR.puts "  - #{url}" }
    end

    raise "example metadata is out of sync"
  end

  #
  # To build your initial window/screen, use the screen object provided to you in `setup`.
  #
  # `setup` runs once at the begining of the application. You define it and you have the `Lvgl`
  # API available to you.
  #
  # Here, we just print to the console that all of the examples are being run at once. This is
  # because we included them all at the top of this source file with `require "./examples/**"`.
  # That means that every example class was included in our application and will be invoked by
  # `Lvgl.main`.
  #
  # Browse the [example sources](examples/) for the example you'd like to run.
  def setup(screen)
    Log.info { "Running all examples at once!" }
  end

  # Called repeatedly to allow you to update UI content
  def loop(screen, message)
  end

  # Called once when the application is closing
  def cleanup(screen)
    Log.info { "Cleaning up!" }
  end
end

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
# * Each example inherits the `Lvgl::Applet` class to simplify integration.
# * Each example implements the `setup`, `loop`, and `cleanup` methods if appropriate.
# * The lifecyle is managed by `Lvgl.main`.
# * The backend can be set with the LVGL_BACKEND environment variable.
# * The `liblvgl.so` library is linked dynamically and available backends are configured at run-time.
#
# ### Example image index (macro-generated from `@[Lvgl::ExampleMetadata(...)]`)
#
{% for subclass in Lvgl::Applet.all_subclasses %}
  {% metadata = subclass.annotation(Lvgl::ExampleMetadata) %}
  {% if metadata %}
# #### {{ metadata[:section] }}
#
# {{ metadata[:title] }}
#
# `{{ subclass.name.stringify }}`
#
# ![{{ subclass.name.stringify }}]({{ metadata[:image_path] }})
#
#
  {% end %}
{% end %}

class Examples < Lvgl::Applet
  # Canonical metadata record collected from @[Lvgl::ExampleMetadata(...)] annotations.
  record DocsEntry,
    applet_class : Lvgl::Applet.class,
    class_name : String,
    section : String,
    title : String,
    image_path : String do
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
          image_path: {{ metadata[:image_path] }}
        )
      {% end %}
    {% end %}

    entries
  end

  # Returns metadata entries for all annotated applets.
  def self.docs_entries : Array(DocsEntry)
    DOCS_ENTRIES
  end

  # Ensures every registered applet (except this aggregate runner) is annotated
  # and that there are no stale metadata entries.
  def self.validate_docs_metadata! : Nil
    documented_names = docs_entries.map(&.class_name)
    registered_names = Lvgl::Applet.registry.map(&.new.class_name).reject { |name| name == "Examples" }

    missing_metadata = registered_names.reject { |name| documented_names.includes?(name) }
    stale_metadata = documented_names.reject { |name| registered_names.includes?(name) }

    return if missing_metadata.empty? && stale_metadata.empty?

    STDERR.puts "Example metadata mismatch detected:"
    unless missing_metadata.empty?
      STDERR.puts "- Applets missing @[Lvgl::ExampleMetadata(...)] annotation:"
      missing_metadata.sort.each { |name| STDERR.puts "  - #{name}" }
    end

    unless stale_metadata.empty?
      STDERR.puts "- Metadata entries without registered applets:"
      stale_metadata.sort.each { |name| STDERR.puts "  - #{name}" }
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

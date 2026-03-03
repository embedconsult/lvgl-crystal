ENV["LVGL_NO_AUTORUN"] = "1"

require "log"
require "./examples/**"

# An applet is an easy way to build an LVGL application in Crystal.
#
# Each example is written as an applet. To make an applet, define your application
# as a class that inherits `Lvgl::Applet`.
#
# To invoke the menu from the command-line:
#
# ```bash
# crystal run src/examples.cr
# ```
#
# Then select one of the listed examples from the LVGL menu.
#
# ### Background summary:
# * [Original C examples](https://docs.lvgl.io/9.4/examples.html)
# * Every local example must map 1-to-1 to a single LVGL upstream example URL.
# * Each example inherits the `Lvgl::Applet` class to simplify integration.
# * Each example implements the `setup`, `loop`, and `cleanup` methods if appropriate.
# * The backend can be set with the LVGL_BACKEND environment variable.
# * The `liblvgl.so` library is linked dynamically and available backends are configured at run-time.
#
# ### Example gallery
#
# Browse all documented examples from one page in Crystal docs via
# `Examples::DocsGallery`.
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

  @active_example : Lvgl::Applet?
  @event_subscriptions = [] of Lvgl::Event::Subscription
  @status_label : Lvgl::Label?

  # Build an LVGL menu that can launch one example at a time.
  def setup(screen)
    Log.info { "Opening examples menu" }

    title = Lvgl::Label.new(screen)
    title.text = "LVGL Crystal Examples"
    title.position = {10, 10}

    status_label = Lvgl::Label.new(screen)
    status_label.text = "Tap a button to launch an example"
    status_label.position = {10, 34}
    @status_label = status_label

    menu_entries.each_with_index do |entry, index|
      button = Lvgl::Button.new(screen)
      button.set_size(420, 32)
      button.position = {10, 64 + (index * 38)}

      label = Lvgl::Label.new(button)
      label.text = "#{entry.section}: #{entry.title}"
      label.center

      subscription = button.on_event(Lvgl::Event::Code::Clicked) do
        launch_example(entry, screen)
      end
      @event_subscriptions << subscription
    end
  end

  # Called repeatedly to allow the selected example to update UI content.
  def loop(screen, message)
    @active_example.try &.loop(screen, message)
  end

  # Called once when the application is closing.
  def cleanup(screen)
    @active_example.try &.cleanup(screen)
    @event_subscriptions.each(&.release)
    @event_subscriptions.clear
    Log.info { "Cleaning up examples menu" }
  end

  private def menu_entries : Array(DocsEntry)
    self.class.docs_entries.sort_by { |entry| {entry.section, entry.title} }
  end

  private def launch_example(entry : DocsEntry, screen : Lvgl::Object) : Nil
    @active_example.try &.cleanup(screen)

    applet = entry.applet_class.new
    @active_example = applet
    @status_label.try do |label|
      label.text = "Running: #{entry.section} / #{entry.title}"
    end

    Log.info { "Launching #{entry.class_name}" }
    applet.setup(screen)
  end
end

if !PROGRAM_NAME.downcase.includes?("spec")
  Examples.validate_docs_metadata!
  Lvgl.main([Examples])
end

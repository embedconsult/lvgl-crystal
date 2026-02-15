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
# ### Examples:
# * [Get Started](#get-started)
#
# ### Background summary:
# * [Original C examples](https://docs.lvgl.io/9.4/examples.html)
# * Each example inherits the `Lvgl::Applet` class to simplify integration.
# * Each example implements the `setup`, `loop`, and `cleanup` methods if appropriate.
# * The lifecyle is managed by `Lvgl.main`.
# * The backend can be set with the LVGL_BACKEND environment variable.
# * The `liblvgl.so` library is linked dynamically and available backends are configured at run-time.
#
# ## Get Started
#
# ### A very simple _hello world_ label
#
# `ExampleGetStarted1`
#
# ![ExampleGetStarted1](images/lv_example_get_started_1.png)
#
# ### A button with a label and react on click event
#
# `ExampleGetStarted2`
#
# ![ExampleGetStarted2](images/lv_example_get_started_2.png)
#
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
class Examples < Lvgl::Applet
  # Called once to setup your applet
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

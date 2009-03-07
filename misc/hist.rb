#!/usr/bin/env ruby

require 'gnomecanvas2'

#class HistogramModel < GLib::Object
#  # TODO: signals
#
#  signal_new("changed",
#    GLib::Signal::RUN_FIRST,
#    nil,
#    nil,
#    String)
#
#  def initialize
#    super
#    @model = Hash.new(nil)
#  end
#
#  def set(x, y)
#    @model[x] = y
#    # see if something changed...
#    # signal_emit("changed", ...)
#  end
#
#  def set_xfunc(&block)
#    @xfunc = block
#  end
#
#  def set_yfunc(&block)
#    @yfunc = block
#  end 
#
#  def set_labelfunc(&block)
#    @labelfunc = block
#  end
#
#  def each_pair(&block)
#    @model.each_pair do |x, y|
#      block.call(@xfunc.call(x), @yfunc.call(y))
#    end
#  end
#end

# TODO: allow bars with different widths (for log-log)
class Histogram < Gnome::Canvas
  def initialize(*args)
    super(*args)
    @model = {3 => ["lua", "sol"], 4 => ["casa", "rosa"], 6 => ["arara"],
        1 => %w(a e i o u)}
    @bars = @model.dup
   
    @bars.each_pair do |k, v|
      @bars[k] = Gnome::CanvasRect.new(self.root,
          :x1 => 0,
          :y1 => 0,
          :x2 => 0,
          :y2 => 0,
          :fill_color => "blue",
          :outline_color => "black")
      @bars[k].signal_connect("event") do |item, ev|
        if ev.kind_of?(Gdk::EventCrossing)
          item.fill_color = (ev.event_type == Gdk::Event::ENTER_NOTIFY) ? \
              "red" : "blue"
        end
      end
    end

    @pw_unit = 50
    @ph_unit = 50

    @mw_model = @model.keys.max
    @mh_model = @model.values.map{|x|x.size}.max
    @pw_model = @mw_model * @pw_unit
    @ph_model = @mh_model * @ph_unit

    signal_connect("size-allocate") do |w, e|
      @w_scroll = [e.width, @pw_model].max
      @h_scroll = [e.height, @ph_model].max

      set_scroll_region(0, 0, @w_scroll, @h_scroll)
      size_changed
    end
  end

  def set_scale(x, y)
    @pw_unit, @ph_unit = x, y
  end

  def size_changed
    @bars.each_pair do |k, v|
      height = @ph_unit * @model[k].size
      x = k * @pw_unit

      v.x1 = x
      v.y1 = @h_scroll
      v.x2 = x + @pw_unit
      v.y2 = @h_scroll - height
    end
  end

end

Gtk.init

window = Gtk::Window.new
window.signal_connect("destroy") { Gtk.main_quit }

scroll = Gtk::ScrolledWindow.new
scroll.add(Histogram.new)
window.add(scroll)

window.show_all

Gtk.main



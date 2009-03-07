#!/usr/bin/env ruby

require 'gnomecanvas2'

#class HistogramModel < GLib::Object
#  # TODO: signals
#
#  def initialize
#    signal_new("changed",
#        GLib::Signal::RUN_FIRST,
#        nil,
#        nil,
#        String)
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

class Tooltip < Gnome::CanvasGroup
  def initialize(*args)
    super(*args)

    # TODO: use signals: signal_emit("selected"...)
    signal_new("selected",
        GLib::Signal::RUN_FIRST,
        nil,
        nil,
        String)

    @tip_rect = Gnome::CanvasRect.new(self, 
        :x1 => 0,
        :y1 => 0,
        :x2 => 0,
        :y2 => 0,
        :fill_color => "yellow")
    @tip_text = Gnome::CanvasText.new(self, 
        :x => 2,
        :y => 2 + 6,
        :anchor => Gtk::ANCHOR_WEST,
        :fill_color => "black")

  end

  def text=(text)
    @tip_text.text = text
    @tip_rect.x2 = @tip_rect.x1 + @tip_text.text_width + 4
    @tip_rect.y2 = @tip_rect.y1 + @tip_text.text_height + 4
  end
end

class HistogramBar < Gnome::CanvasRect; end

# TODO: allow bars with different widths (for log-log)
class HistogramCanvas < Gnome::Canvas
  def initialize(*args)
    super
    @model = {3 => ["lua", "sol"], 4 => ["casa", "rosa"], 6 => ["arara"],
        1 => %w(a e i o u)}

    @bars = Hash.new
    @model.each_pair do |k, v|
      bar = HistogramBar.new(self.root,
          :x1 => 0,
          :y1 => 0,
          :x2 => 0,
          :y2 => 0,
          :fill_color => "blue",
          :outline_color => "black")
      @bars[bar] = [k, v]
      bar.signal_connect("event") do |item, ev|
        if ev.kind_of?(Gdk::EventCrossing) && item.kind_of?(HistogramBar)
          if ev.event_type == Gdk::Event::ENTER_NOTIFY
            item.fill_color = "red"
            data = @bars[item]
            if @on_selection_block
              @on_selection_block.call(data)
            end
          elsif ev.event_type == Gdk::Event::LEAVE_NOTIFY
            item.fill_color = "blue"
          end
        end
      end
    end

    self.signal_connect("show") do
      @bars.keys.each { |b| b.show }
    end

    set_scale(50, 50, false)

    signal_connect("size-allocate") do |w, e|
      @w_scroll = [e.width, @pw_model].max
      @h_scroll = [e.height, @ph_model].max

      set_scroll_region(0, 0, @w_scroll, @h_scroll)
      update
    end
  end

  def set_scale(x, y, do_update=true)
    @pw_unit = x
    @ph_unit = y

    @mw_model = @model.keys.max
    @mh_model = @model.values.map{|x|x.size}.max
    @pw_model = (1 + @mw_model) * @pw_unit
    @ph_model = @mh_model * @ph_unit
      
    @w_scroll = [self.width, @pw_model].max
    @h_scroll = [self.height, @ph_model].max

    set_scroll_region(0, 0, @w_scroll, @h_scroll)

    update if do_update
  end

  def scale_by_factor(factor)
    set_scale(@pw_unit * factor, @ph_unit * factor)
  end

  # TODO: replace by signal
  def on_selection(&block)
    @on_selection_block = block
  end

  def update
    @bars.each_pair do |bar, pair|
      x = pair[0] * @pw_unit
      height = @ph_unit * pair[1].size

      bar.x1 = x
      bar.y1 = @h_scroll
      bar.x2 = x + @pw_unit
      bar.y2 = @h_scroll - height
    end
  end

end

class HistogramWidget < Gtk::VBox
  def initialize(*args)
    super(*args)

    @scroll = Gtk::ScrolledWindow.new
    @histogram = HistogramCanvas.new
    @scroll.add(@histogram)

    @toolbar = Gtk::HBox.new
    @bt_plus = Gtk::Button.new(Gtk::Stock::ZOOM_IN)
    @bt_minus = Gtk::Button.new(Gtk::Stock::ZOOM_OUT)
    @info_bar = Gtk::Label.new
    @toolbar.pack_start(@bt_plus, false, false)
    @toolbar.pack_start(@bt_minus, false, false)
    @toolbar.pack_end(@info_bar, true, true)

    self.pack_start(@scroll, true, true)
    self.pack_end(@toolbar, false, true)

    @bt_minus.signal_connect("clicked") { @histogram.scale_by_factor(0.9) }
    @bt_plus.signal_connect("clicked") {  @histogram.scale_by_factor(1.1) }
    @histogram.on_selection do |data|
      @info_bar.text = data.inspect
    end

    self.signal_connect("show") do
      @toolbar.show_all
      @scroll.show
      @histogram.show
    end
  end
end

if __FILE__ == $0
  Gtk.init

  window = Gtk::Window.new
  window.signal_connect("destroy") { Gtk.main_quit }

  hist = HistogramWidget.new
  window.add(hist)
  window.set_default_size(640, 480)

  hist.show
  window.show

  Gtk.main
end


#!/usr/bin/env ruby

require 'gnomecanvas2'

class Point
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def to_a
    [@x, @y]
  end

  def -(p)
    Point.new(@x - p.x, @y - p.y)
  end  
end

class Caixa < Gtk::VBox
  def initialize
    super

    @offset = 10

    @canvas = Gnome::Canvas.new(true) # XXX
    add(@canvas)

    @face = Gnome::CanvasEllipse.new(@canvas.root, 
        :x1 => 20,
        :y1 => 20,
        :x2 => 50,
        :y2 => 50,
        :fill_color => "red",
        :outline_color => "steelblue",
        :width_pixels => 1)
   

    @face.signal_connect("event") do |item, ev|      
      if ev.kind_of?(Gdk::EventCrossing)
        @face.fill_color = ev.event_type == Gdk::Event::ENTER_NOTIFY ? "yellow" : "red"
      end
    end

  signal_connect_after("hide") { puts "hide" }
  signal_connect_after("show") do
    @tid = Gtk::timeout_add(100) { update; true } 
  end
  signal_connect_after("size-allocate") do |w, e|
    @width, @height = e.width, e.height
    @canvas.set_scroll_region(0, 0, @width, @height)
    false
  end

  end  

  def update
    if @face.x2 >= @width || @face.x1 <= 0 
      @offset = -@offset
    end

    @face.x1 = @face.x1 + @offset
    @face.x2 = @face.x2 + @offset
  end
end

Gtk.init

window = Gtk::Window.new
window.signal_connect("destroy") { Gtk.main_quit }
window.add(Caixa.new)
window.show_all

Gtk.main



#!/usr/bin/env ruby
require 'libglade2'
require 'exif'
require 'find'
require 'fileutils'
include FileUtils::Verbose

module Screen
  extend GetText
  
  def Screen.init(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    bindtextdomain(domain, localedir, nil, "UTF-8")
    @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) {|handler| method(handler)}
  end

  def Screen.glade
    @glade
  end

  def Screen.new_page(page=nil, text='...')
    notebook = @glade['notebook']
    page ||= Gtk::HBox.new(false, 0)
    
    close_button = Gtk::Image.new(Gtk::Stock::CLOSE, Gtk::IconSize::MENU)
    close_button = Gtk::EventBox.new.add(close_button)
    close_button.signal_connect('button-press-event') do |widget, event|
      if event.button == 1
        notebook = notebook
        notebook.remove_page(notebook.page_num(page))
      end
      true
    end

    label = Gtk::Label.new(text)

    dialog = Gtk::Dialog.new("Renomear",
        nil,
        Gtk::Dialog::MODAL,
        [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT],
        [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_REJECT])
    entry = Gtk::Entry.new
    entry.activates_default = true
    dialog.default_response = Gtk::Dialog::RESPONSE_ACCEPT
    dialog.vbox.add entry 
    dialog.signal_connect('delete-event') { true }
    dialog.vbox.show_all
    dialog.signal_connect('response') do |dialog, response|
      if response == Gtk::Dialog::RESPONSE_ACCEPT
        label.text = entry.text
      end
      dialog.hide
    end

    eventbox = Gtk::EventBox.new.add(label)
    eventbox.signal_connect('button-press-event') do |widget, event|
      if event.button == 3
        entry.has_focus = true
        entry.text = label.text
        if entry.text =~ / \d\d-\d\d-\d\d\d\d/
          entry.select_region 0, $~.begin(0)
        else
          entry.select_region 0, -1
        end
        dialog.show_all
      end
    end

    tab_label = Gtk::HBox.new(false, 2)
    tab_label.pack_start eventbox, true
    tab_label.pack_start close_button
    tab_label.show_all

    notebook.append_page(page, tab_label)
    notebook.set_tab_reorderable(page, true)
    return page
  end

end


# TODO: imagem do drag-and-drop eh muito grande. diminuir.
class ImageList < Gtk::ScrolledWindow
  TARGET = ["photo", Gtk::Drag::TARGET_SAME_APP, 1]
  THUMB_SIZE = 128

  attr_reader :model

  def new_store
    return Gtk::ListStore.new(String, String, Gdk::Pixbuf, Time)
  end

  def initialize(file_list)
    super()
    
    if file_list.kind_of? Array
      @model = new_store
      file_list.each { |path, basename, time| append_row(path, basename, time) }
    elsif file_list.kind_of? Gtk::ListStore
      @model = file_list
    end
    
    @treeview = Gtk::TreeView.new(@model)
    @treeview.selection.mode = Gtk::SELECTION_MULTIPLE
    @treeview.signal_connect('key-press-event') { |widget, event|
      remove_selected if event.keyval == 65535
    }
    @treeview.signal_connect('row-activated') do |treeview, path, column|
      # TODO: configurable viewer
      Process.fork { exec "eog", "#{@model.get_iter(path)[0]}" }
    end

    connect_drag_n_drop

    #Dir.glob(glob) { |file| append_row file.chomp }

    renderer = Gtk::CellRendererPixbuf.new
    col = Gtk::TreeViewColumn.new('Preview', renderer, :pixbuf => 2)
    col.resizable = true
    @treeview.append_column(col)

    renderer = Gtk::CellRendererText.new
    col = Gtk::TreeViewColumn.new('Name', renderer, :text => 1)
    col.resizable = true
    @treeview.append_column(col)

    renderer = Gtk::CellRendererText.new
    col = Gtk::TreeViewColumn.new('Date/Time', renderer)
    col.resizable = true
    col.set_cell_data_func(renderer) do |col, renderer, model, iter|
      time = iter[3]
      renderer.text = iter[3].strftime("%d-%m-%Y %H:%M:%S") 
    end
    @treeview.append_column(col)

    self.create_menu
    self.add @treeview
  end

  def append_row(path, basename, time)
    iter = @model.append
    iter[0] = path
    iter[1] = basename #file[(file.rindex('/')+1)..-1]
    iter[3] = time
    width = Gdk::Pixbuf.get_file_info(path)[1]#.mime_types
    if width == 1
      iter[2] = Gdk::Pixbuf.new('movie.png', THUMB_SIZE, THUMB_SIZE)
    else
      iter[2] = Gdk::Pixbuf.new(path, THUMB_SIZE, THUMB_SIZE)
    end
  end

  def remove_selected
    iters = []
    @treeview.selection.selected_each { |model, path, iter| iters << iter }
    iters.each { |iter| @model.remove(iter) }
  end

  def create_menu
    menu = Gtk::Menu.new
    item = Gtk::MenuItem.new("Mover para nova pasta")
    item.signal_connect('activate') {
      to_delete = []
      dates = []
      store = new_store
      @treeview.selection.selected_each do |model, path, iter|
        to_delete << iter
        dates << Time.at(iter[3].to_i)
        new_iter = store.append
        4.times { |i| new_iter[i] = iter[i] }
      end
      chars = ("a".."z").to_a #+ ("1".."9").to_a
      prefix = Array.new(6, '').collect{chars[rand(chars.size)]}.join + ' '
      suffix = dates.min.strftime("%d-%m-%Y")
      Screen.new_page(ImageList.new(store), prefix + suffix).show_all

      to_delete.each { |iter| model.remove(iter) }
    }
    menu.append(item)
    item = Gtk::MenuItem.new("Ignorar")
    item.signal_connect('activate') { remove_selected }
    menu.append(item)
    menu.show_all
    
    @treeview.signal_connect('button-press-event') do |widget, event|
      menu.popup(nil, nil, event.button, event.time) if event.button == 3
    end
  end

  def connect_drag_n_drop
    @treeview.enable_model_drag_source(Gdk::Window::BUTTON1_MASK,
        [TARGET],
        Gdk::DragContext::ACTION_MOVE)
    @treeview.enable_model_drag_dest([TARGET], Gdk::DragContext::ACTION_MOVE)

    @treeview.signal_connect('drag-data-get') do |widget, drag_context, data, info, time|
      text = ''
      @treeview.selection.selected_each { |model, path, iter|
        text += "#{iter[0]}:#{iter[1]}:#{iter[3].to_i}\n"
      }
      data.set(Gdk::Selection::TYPE_STRING, text)
      remove_selected
    end

    @treeview.signal_connect("drag-data-received") do |w, dc, x, y, selectiondata, info, time|
      selectiondata.text.each_line { |file| 
        x = file.chop.split(':')
        append_row x[0], x[1], Time.at(x[2].to_i)
      }
      true
    end
   
    # TODO: doesn't work
    Gtk::Drag.source_set_icon(@treeview, Gtk::Stock::CLOSE)
    @treeview.signal_connect('drag-begin') do |treeview, dc|
      Gtk::Drag.set_icon_name(dc, 'gtk-copy', 16, 16)
    end
  end
end

def get_date(filename)
  #cam_exif = Exif.new(filename)#['Date and Time']
  #cam_exif = (cam_exif.list_tags(2).empty? ? nil : cam_exif['Date and Time'])
  #if cam_exif.nil?
    return File.mtime(filename)
  #else
  #  d = cam_exif.split(/[ :]/).map { |x| x.to_i }
  #  return Time.local(*d)
  #end
end

def include_file?(cam_path, date, local_files)
  basename = File.basename(cam_path).upcase
  matches = local_files.select { |e| File.basename(e).upcase == basename }
  #if matches.empty? then return true end
  #date = get_date(cam_path)
  matches.each do |local|
    return false if date == get_date(local)
    #&& File.size(local) == File.size(cam_path)
  end

  return true
end

def mount(mount_point)
  unless mount_point.empty?
    `mount #{mount_point}`
    raise "Couldn't mount #{mount_point}" if $? != 0
  end
end

def umount(mount_point)
  unless mount_point.nil? || mount_point.empty?
    `umount #{mount_point}`
    #raise "Couldn't mount #{mount_point}" if $? != 0
  end
end

# Main program
if __FILE__ == $0
begin
  # Set values as your own application. 
  PROG_PATH = "descarrega.glade"
  PROG_NAME = "YOUR_APPLICATION_NAME"
  Screen.init(PROG_PATH, nil, PROG_NAME)
  t = Screen
  
  notebook = t.glade['notebook']
  from_dir = ''
  to_dir = ''
  search_dir = ''
  mount_point = ''

  window = t.glade['window']
  
  dialog = t.glade['dialog']
  dialog.signal_connect('destroy') { Gtk.main_quit }
  t.glade['cancel'].signal_connect('clicked') { Gtk.main_quit }

  extensions = ['jpg', 'jpeg', 'mpg']
  extensions.map! { |e|
    s = '*.'
    e.scan(/./m) { |c| s += "[#{c.upcase}#{c.downcase}]" }
    s }
  file_mask = "{" + extensions.join(",") + "}"

  ###########

  t.glade['ok'].signal_connect('clicked') { 
    dialog.hide_all
  
    from_dir = t.glade['source_dir'].text
    to_dir = t.glade['destination_dir'].text
    search_dir = t.glade['search_dir'].text
    mount_point = t.glade['mount_point'].text

    local_files = []
    Find.find(search_dir) { |path| local_files << path }

    mount(mount_point)
    Dir.foreach(from_dir) do |dir|
      list = []
      path = "#{from_dir}/#{dir}"
      if File.directory?(path) && dir[0,1] != '.'
        dates = []
        Dir.glob("#{path}/**/#{file_mask}") do |file|
          date = get_date(file)
          if include_file? file, date, local_files
            list << [file, file[(path.size + 1)..-1], date]
            dates << date
          end
        end
        suffix = dates.min.strftime(' %d-%m-%Y')
        
        Screen.new_page(ImageList.new(list), dir + suffix) unless list.empty?
      end
    end
    
    window.show_all
  }
  
  window.signal_connect('destroy') { umount(mount_point); Gtk.main_quit }

  ###########


  t.glade['copy'].signal_connect('clicked') do |widget, event|
    notebook.n_pages.times do |i|
      page = notebook.get_nth_page(i)
      folder =  notebook.get_tab_label(page).children[0].children[0].text
      dest = "#{to_dir}/#{folder}"
      begin
      mkdir dest # TODO: tratar excecao "arquivo ja existe"
      rescue
      end
      page.model.each do |model, path, iter|
        src = iter[0]
        cp src, dest, :preserve => true
      end
    end
  end

  #window.show_all
  dialog.show_all
  Gtk.main
ensure
  umount(mount_point)
end
end


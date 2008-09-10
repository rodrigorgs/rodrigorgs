#db.execute('select * from sqlite_sequence')
#=> [["supermercado", "3"]]


require 'gtk2'

window = Gtk::Window.new #(Gtk::WINDOW_TOPLEVEL)
window.set_title("Hello Ruby")
window.border_width = 10
#button = Gtk::Button.new("Hello World")

store = Gtk::ListStore.new(String)
%w(BOMPRECO EXTRA GBARBOSA IDEAL MINASMAR).each { |w| store.append[0] = w }
completion = Gtk::EntryCompletion.new
completion.model = store
completion.text_column = 0
item = Gtk::Entry.new
item.completion = completion

hbox = Gtk::HBox.new(false, 0)
hbox.pack_start item, false, false
window.add hbox


# Connect the button to a callback.
#button.signal_connect('clicked') { puts "Hello Ruby" }

# Connect the signals 'delete_event' and 'destroy'
window.signal_connect('delete_event') {
  puts "delete_event received"
  false
}
window.signal_connect('destroy') {
  puts "destroy event received"
  Gtk.main_quit
}

window.show_all
Gtk.main
#class DbModel < Gtk::ListStore
#  def initialize
#    super.destroy    
#  end
#
#  def set(db, table, column)
#    @iter = DbIter.new(db, table, column)
#  end
#
#
#  def flags
#    0
#  end
#
#  def n_columns
#    1
#  end
#
#  def get_column_type
#    String
#  end
#
#  def iter_first
#    @iter
#  end
#
#  def get_iter(path)
#  end
#
#  def get_value(iter, col)
#    @iter[col]
#  end
#  
#end
#
#class DbIter < Gtk::TreeIter
#  def initialize(db, table, column)
#    @db, @table, @column = db, table, column
#    do_query
#    @value = nil
#  end
#
#  def do_query
#    @db.query("select distinct #{@column} from #{@table} order by #{@column} asc") {|set|
#      @set = set
#    }
#  end
#
#  def first!
#    #@set.reset 
#    do_query
#  end
#
#  def [](col)
#    @value[col]
#  end
#  alias get_value []
#
#  def next!
#    @value = @set.next ? true : false
#  end
#
#  def first_child
#    nil
#  end
#
#  def has_child?
#    false
#  end
#
#  def n_children
#    0
#  end
#
#  def nth_child(n)
#    nil
#  end
#
#  def parent
#    nil
#  end
#
#  def path
#    # ???
#  end
#
#  def []=(col, value)
#    # do nothing
#  end
#  alias set_value []
#end

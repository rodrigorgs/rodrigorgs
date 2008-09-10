# TODO: TreeModelFilter

require 'ui'
require 'sqlite3'

LISTA_HEADERS = [
  {:col => 'item.id', :header => nil, :type => Integer},
  {:col => 'compra.id', :header => nil, :type => Integer},
  {:col => 'produto.id', :header => nil, :type => Integer},
  {:col => 'supermercado.nome', :header => "Supermercado", :type => String},
  {:col => 'compra.data', :header => 'Data', :type => String},
  {:col => 'produto.nome', :header => 'Produto', :type => String},
  {:col => 1, :header => 'Valor', :type => Float},
  {:col => 'item.qtd', :header => 'Qtd', :type => Float},
  {:col => 'item.valor', :header => 'Total', :type => Float},
  {:col => 'item.obs', :header => 'Obs.', :type => String}
]

INDEX = Hash.new
LISTA_HEADERS.each_with_index { |obj, j| INDEX[obj[:col]] = j } 

class TelaGlade
  def db=(db)
    @db = db
  end

  def update_completions
    load_completion 'supermercado', 'supermercado', 'nome'
    load_completion 'produto', 'produto', 'nome'

    @glade['busca'].completion = @glade['produto'].completion
    @glade['busca'].signal_connect('activate') do
      update_lista('%' + @glade['busca'].text + '%')
      false
    end
  end

  def update_valores_por_compra(compra_id, iter)
    soma = 0.0
    
    #@db.execute("select valor from item where compra = #{compra_id}").flatten.
    #  map{|e| e.to_f}.each {|valor| soma += valor}
    #iter = @glade['lista'].model.iter_first
    i = INDEX['compra.id']
    iter[i] = soma
    #begin
    #  if iter[index] == compra_id
    #    iter[index] = soma
    #    break
    #  end
    #end while iter.next!
  end

  def update_lista(pattern='%')
    x = @glade['lista']
    types = LISTA_HEADERS.map {|e| e[:type]}
    store = Gtk::TreeStore.new *types
    @db.execute('select id, data, supermercado from compra') do |compra|
      parent = store.append(nil)
      parent[INDEX['compra.data']] = compra[1]
      parent[INDEX['supermercado.nome']] = @db.get_first_value("select nome from supermercado where id = #{compra[2]}")

      cols = LISTA_HEADERS.map {|e| e[:col]}.select{|e| e.kind_of? String}
      query = <<-SQL
        select #{cols.join(',')}
        from item
        inner join compra on item.compra = compra.id
        inner join supermercado on compra.supermercado = supermercado.id
        inner join produto on item.produto = produto.id
        where compra.id == #{compra[0]}
          and produto.nome like \"#{pattern}\"
      SQL
      soma = 0.0
      @db.execute(query) do |item|
        child = store.append(parent)
        cols.each_with_index do |col, i|
          child[INDEX[col]] = item[i]
        end
        child[INDEX[1]] = child[INDEX['item.valor']].to_f / child[INDEX['item.qtd']]
        soma += child[INDEX['item.valor']].to_f
      end
      parent[INDEX['item.valor']] = soma
    end
    store.signal_connect('row-changed') { |store, path, iter|
      # TODO
    }

    store = Gtk::TreeModelSort.new(store)
    x.model = store
  end

  def load_completion(widget, table, column)
    x = @glade[widget]
    store = Gtk::ListStore.new(String)
    @db.execute("select distinct #{column} from #{table}").flatten.each { |w| 
      store.append[0] = w
    }
    completion = Gtk::EntryCompletion.new
    completion.model = store
    completion.text_column = 0
    x.completion = completion
  end

  def mark_days
    data = @glade['data']
    data.clear_marks

    y,m,d = data.date
    query = 'select distinct data from compra where data LIKE "%04d%02d__"' % [y,m]
    @db.execute(query).flatten.each { |s| data.mark_day(s[6,2].to_i) }
  end

  def on_data_month_changed
    mark_days
  end

  def on_adicionar_clicked
    if %w(supermercado produto qtd valor).any? { |x| @glade[x].text == '' }
      dialog = Gtk::MessageDialog.new(@glade['windows'],
          Gtk::Dialog::MODAL,
          Gtk::MessageDialog::ERROR,
          Gtk::MessageDialog::BUTTONS_CLOSE,
          "Campo obrigatorio vazio.")
      dialog.run
      dialog.destroy

      return
    end

    compra_id = @db.compra_id(
        @glade['supermercado'].text,
        "%04d%02d%02d" % @glade['data'].date)
    produto_id = @db.produto_id(@glade['produto'].text)

    @db.execute 'insert into item(compra, produto, qtd, valor, obs) ' + 
        'values(?,?,?,?,?)',
        compra_id,
        produto_id,
        @glade['qtd'].text.to_f,
        @glade['valor'].text.to_f,
        @glade['obs'].text

    reset_fields
    update_completions
    update_lista
  end

  def reset_fields
    @glade['produto'].text = ''
    @glade['qtd'].text = ''
    @glade['valor'].text = ''
    @glade['obs'].text = ''
    @glade['produto'].has_focus = true
  end
end

class SQLite3::Database
  def get_id(table, hash)
    where = []
    hash.each_pair { |k, v| where << "#{k} #{v.class == String ? '=' : '='} #{v.inspect}" }

    query = "select id from #{table} where " + where.join(" AND ")
    id = get_first_value(query)
    if id.nil?
      query = "insert into #{table} (#{hash.keys.join(',')}) values(#{hash.values.map{|x| x.inspect}.join(',')})"
      execute(query)
      id = get_first_value('select seq from sqlite_sequence where name = ?', table)
    end
    return id.to_i
  end

  def get_id_from_name(table, nome)
    get_id table, {'nome' => nome}
  end

  def supermercado_id(nome)
    get_id 'supermercado', {'nome' => nome}
  end

  def produto_id(nome)
    get_id 'produto', {'nome' => nome}
  end

  def compra_id(supermercado, data)
    get_id 'compra', {
      'supermercado' => supermercado_id(supermercado),
      'data' => data}
  end
end

# Main program
if __FILE__ == $0
  db = SQLite3::Database.new 'supermercado.db'
  db.type_translation = true

  # Set values as your own application. 
  PROG_PATH = "supermercado.glade"
  PROG_NAME = "RoDen Supermercado"
  t = TelaGlade.new(PROG_PATH, nil, PROG_NAME)
  t.db = db

  lista = t.glade['window']
  lista.signal_connect('delete_event') { false }
  lista.signal_connect('destroy') { Gtk.main_quit }
  lista.show_all

  now = Time.now
  t.glade['data'].select_month(now.month, now.year)
  t.glade['data'].select_day(now.day)

  t.glade['insercao'].focus_chain = 
      %w(supermercado produto qtd valor obs adicionar).map { |w| t.glade[w] }

  lista = t.glade['lista']
  lista.signal_connect('row-activated') do |treeview, path, column|
    iter = treeview.model.get_iter(path)
    if iter[INDEX['produto.nome']].nil?
      str = iter[INDEX['compra.data']]
      y, m, d = str[0,4].to_i, str[4,2].to_i, str[6,2].to_i
      t.glade['data'].select_month(m, y)
      t.glade['data'].select_day(d)
      t.glade['supermercado'].text = iter[INDEX['supermercado.nome']]
      t.glade['notebook'].page = 1
      t.glade['produto'].has_focus = true
    end
  end

  LISTA_HEADERS.each_with_index do |header_info, i|
    next if header_info[:header].nil?

    renderer = Gtk::CellRendererText.new
    if ([1] + %w(item.obs item.qtd item.valor)).include? header_info[:col]
      renderer.editable = true
      renderer.signal_connect('edited') { |renderer, row, new_text|
        iter = lista.model.model.get_iter(row)
        if iter[INDEX['produto.nome']].nil?
          true
        else
          col = header_info[:col]
          old_value = iter[INDEX[col]]

          type = header_info[:type]
          value = type == String ? new_text : type.instance_eval(new_text)
          lista.model.model.set_value(iter, i, value)
          case col
          when 'item.valor'
            iter[INDEX[1]] = iter[INDEX['item.valor']].to_f / iter[INDEX['item.qtd']]
            iter.parent[INDEX['item.valor']] += (value - old_value)
          when 'item.qtd', 1
            old_item_valor = iter[INDEX['item.valor']]
            iter[INDEX['item.valor']] = iter[INDEX[1]] * iter[INDEX['item.qtd']]
            iter.parent[INDEX['item.valor']] += (iter[INDEX['item.valor']] - old_item_valor)
          end

          value = value.inspect if type == String
          db.execute 'replace into item(id, compra, produto, qtd, valor, obs) ' + 
            'values(?,?,?,?,?,?)',
            iter[INDEX['item.id']], iter[INDEX['compra.id']],
            iter[INDEX['produto.id']], iter[INDEX['item.qtd']],
            iter[INDEX['item.valor']], iter[INDEX['item.obs']]
            false
        end
      }
    end
    c = Gtk::TreeViewColumn.new(header_info[:header] || '...', renderer)
    c.reorderable = true
    c.sort_column_id = i

    case header_info[:col]
    when 'compra.data'
      c.set_cell_data_func(renderer) do |col, renderer, model, iter|
        str = iter[i]
        renderer.text = str[6,2] + '-' + str[4,2] + '-' + str[0,4]
        renderer.foreground = iter[INDEX['produto.nome']].nil? ? 'black' : 'gray'
      end
    when 'item.qtd'
      c.set_cell_data_func(renderer) do |col, renderer, model, iter|
        if iter[INDEX['produto.nome']].nil?
          renderer.text = ''
        else
          n = iter[i].to_f
          renderer.text = (n == n.to_i) ? (n.to_i.to_s) : ("%.3f" % n)
        end
      end
    when 'item.valor', 1
      c.set_cell_data_func(renderer) do |col, renderer, model, iter|
        renderer.xalign = 1.0
        renderer.text = "%.2f" % iter[i].to_f 
        if iter[INDEX['produto.nome']].nil? && iter.has_child?
          renderer.text = '' if header_info[:col] == 1
          renderer.weight = Pango::WEIGHT_BOLD
        else
          renderer.weight = Pango::WEIGHT_NORMAL
        end
      end
    when 'supermercado.nome'
      c.set_cell_data_func(renderer) do |col, renderer, model, iter|
        renderer.text = iter[i]
        renderer.foreground = iter[INDEX['produto.nome']].nil? ? 'black' : 'gray'
      end
    else
      c.set_attributes renderer, :text => i
    end
    c.sizing = Gtk::TreeViewColumn::FIXED
    c.fixed_width = 70
    c.resizable = true
    lista.append_column c
  end
  lista.headers_clickable = true

  lista.signal_connect('key_press_event') do |widget, event|
    if event.keyval == 65535 #delete
      widget.selection.selected_each { |modelsort, path, iter|
        iter = modelsort.convert_iter_to_child_iter(iter)
        unless iter[INDEX['produto.nome']].nil?
          db.execute("delete from item where id = #{iter[INDEX['item.id']]}")
          modelsort.model.remove iter
        end
      }
    end
  end

  t.mark_days
  t.update_completions
  t.update_lista

  #lista.signal_connect('configure-event') { puts 3; columns_autosize }
  Gtk.main
end

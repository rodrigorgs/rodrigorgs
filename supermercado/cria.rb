require 'sqlite3'

db = SQLite3::Database.new 'supermercado.db'

db.execute_batch <<SQL
  create table supermercado(
    id   integer primary key autoincrement,
    nome text not null,
    obs  text
  );

  create table produto(
    id   integer primary key autoincrement,
    nome text not null,
    obs  text
  );

  create table compra(
    id           integer primary key autoincrement,
    supermercado integer not null,
    data         text not null,
    obs          text
  );

  create table item(
    id      integer primary key autoincrement,
    compra  integer not null,
    produto integer not null,
    qtd     real not null,
    valor   real not null,
    obs     text
  );
SQL
    #CONSTRAINT unico_item UNIQUE (compra, produto)

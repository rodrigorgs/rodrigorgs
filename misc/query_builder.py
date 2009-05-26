#!/usr/bin/env python
# :map <F5> :w<CR>:!python %<CR>

import os, sys, re

data = {
'i_instrumentolegal' :
  {'pedido' : [['codigosiga', 'cod_pedido'], ['anopedido', 'exercicio']],}
}

default_aliases = {
  'il' : 'i_instrumentolegal',
  'ped' : 'pedido',
  'mod' : 'modalidade',
  'dot' : 'i_dotacaoorcamentaria',
  'par' : 'i_parcela',
  'dp' : 'i_dotacaoparcela',
  'db' : 'dotacao_bolsa',
}
  
PSQL = "echo -e \"\\pset pager \n SELECT DISTINCT tgargs FROM pg_trigger WHERE tgname LIKE 'RI_ConstraintTrigger%'\" | psql -t"
put, get = os.popen4(PSQL)
for line in get.readlines():
  line = line.strip()
  if line.find('\\000') != -1:
    fields = [x.strip() for x in line.split('\\000')]
    origem = fields[1]
    destino = fields[2]

    if not data.has_key(origem): data[origem] = {}
    if not data[origem].has_key(destino): data[origem][destino] = []
    fields = fields[4:-1]
    for i in range(len(fields)/2):
      data[origem][destino].append([fields[2*i], fields[2*i+1]])

class ProtoQuery:
  def __init__(self):
    self.tables = {}
    self.main = ''
    self.joins = []
    self.tables.update(default_aliases)

  def alias_to_table(self, alias):
    if self.tables.has_key(alias):
      return self.tables[alias]

    alias = re.sub("[1-9]+$", "", alias)
    return self.tables[alias]

def build_query(proto):
  #query = "SELECT *\n"
  query = "FROM %s %s\n" % (proto.alias_to_table(proto.main), proto.main)
  for alias in proto.joins:
    tables = [proto.alias_to_table(x) for x in alias]
    query += "INNER JOIN %s %s " % (tables[0], alias[0])
    i = 0
    if not data[tables[0]].has_key(tables[1]): i = 1
    query += "ON " + \
    " AND ".join(["%s.%s = %s.%s" % (alias[i], a, alias[1-i], b) for a, b in data[tables[i]][tables[1-i]]]) + "\n"

  return query

# str = "i_instrumentolegal il, pedido ped; il; il-ped, il-ped2"
def build_proto(str):
  proto_query = ProtoQuery()

  parts = [x.strip() for x in str.split(";")]
  tables = [x.strip() for x in parts[0].split(",")]
  if len(tables) > 0 and tables[0].strip() != "":
    for clause in tables:
      table, alias = [x.strip() for x in clause.split(" ")]
      proto_query.tables[alias] = table
  proto_query.main = parts[1]
  joins = [x.strip() for x in parts[2].split(",")]
  for clause in joins:
    #fields = [x.strip() for x in re.split(r'([<>-])', clause)]
    #aliases = [fields[0], fields[2], 1]
    #if fields[1] == '<': aliases.reverse()
    #if fields[1] == '<': aliases[2] = 0
    aliases = [x.strip() for x in clause.split("-")]
    proto_query.joins.append(aliases)

  return proto_query

proto = build_proto("\
 ; par ; il-par, ped-il, mod-ped, db-ped, dot-db\
")
print build_query(proto)

##

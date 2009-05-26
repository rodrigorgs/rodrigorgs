#!/usr/bin/env python
# :map <F5> :w<CR>:!python %<CR>

import os, sys, re

print "graph G {"
print "node[shape=box];"

PSQL = "echo -e \"\\pset pager \n SELECT DISTINCT tgargs FROM pg_trigger WHERE tgname LIKE 'RI_ConstraintTrigger%'\" | psql -t"
put, get = os.popen4(PSQL)
for line in get.readlines():
  line = line.strip()
  if line.find('\\000') != -1:
    fields = [x.strip() for x in line.split('\\000')]
    origem = fields[1]
    destino = fields[2]
    print "%s-%s;" % (origem, destino)

print "}"

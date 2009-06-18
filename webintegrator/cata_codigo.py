#!/usr/bin/env python
#
# == Uso ==
#
# Procura os trechos de codigo nos arquivos XML de definicao de layout do WI, 
# localizados em 
#   /var/tomcat5/webapps/ID_DO_PROJETO/WEB-INF/definitions/layouts/
#
# Os parametros sao os nomes dos arquivos XML que serao analisados.
# Se um dos parametros for a palavra NOMES, cada linha apresenta o nome do
# arquivo de onde a linha foi extraida.
#
# == Exemplos ==
#
# Para catar os scripts de todos os arquivos XML, use este programa combinado
# com o find:
#
# find -name '*.xml' | xargs ~/cata_codigo.py
#
# Outro exemplo legal: achar definicoes de funcoes duplicadas e ordenadar por
# numero de vezes em que cada funcao eh definida:
#
# find -name '*.xml' | xargs ~/cata_codigo.py | grep "function " | sort | uniq -c | sort -n | less
#
# Comparar definicoes da funcao formSubmit:
#
# find -name '*.xml' | xargs ~/cata_codigo.py NOMES | grep "function formSubmit"  -A 10 | less

import libxml2
import sys


nomeEmCadaLinha = 'NOMES' in sys.argv
if nomeEmCadaLinha:
  sys.argv.remove('NOMES')

for filename in sys.argv[1:]:
  doc = libxml2.parseDoc(file(filename).read())
  print
  print "//== " + filename + " =="
  print
  for found in doc.xpathEval('//CODE'):
    if nomeEmCadaLinha:
      print "\n".join(["/*" + filename + "*/ " + linha for linha in found.content.split("\n")])
    else:
      print found.content

#vim:set ts=2 sw=2 softtabstop=2 expandtab ai

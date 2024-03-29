#!/usr/bin/env python
# -*- coding: latin-1 -*-
#vim:set ts=2 sw=2 softtabstop=2 expandtab ai

import libxml2
import sys
import re
from elementtree import ElementTree as ET
from xml.dom.minidom import parseString

#import unicodedata
#def remove_accents(str):
#  nkfd_form = unicodedata.normalize('NFKD', unicode(str))
#  only_ascii = nkfd_form.encode('ASCII', 'ignore')
#  return only_ascii

##############################################################################
##############################################################################
##############################################################################
# Extrai campos de um tipo de componente de interface do wizard

class WizAttribute:
  def __init__(self, name):
    self.name = name
    self.default = ""
    self.options = []

  def __str__(self):
    return "" #"%s=%s(%s)" % (self.name, self.default, "|".join(self.options))

filename = "/var/tomcat5/webapps/sigaintranet/WEB-INF/definitions/wiz/elem_campo_texto.xml"

directory = "/var/tomcat5/webapps/sigaintranet/WEB-INF/definitions/wiz/"
filenames = """elem_abas.xml
elem_aviso_banco.xml
elem_aviso.xml
elem_botao_acao.xml
elem_botao_evento.xml
elem_botao.xml
elem_cabecalho.xml
elem_calendario_duplo.xml
elem_calendario_funcao.xml
elem_calendario_simples.xml
elem_calendario.xml
elem_campo_arquivo.xml
elem_campos_ped_il.xml
elem_campo_texto.xml
elem_checkbox.xml
elem_combo_meses.xml
elem_combo.xml
elem_dados_pedido.xml
elem_dual_list.xml
elem_editor.xml
elem_faixa.xml
elem_form_fim.xml
elem_form_ini.xml
elem_grid_java.xml
elem_oculto.xml
elem_pesquisar_exerc.xml
elem_pesquisar.xml
elem_radio.xml
elem_rodape.xml
elem_span_fim.xml
elem_span_ini.xml
elem_text_area_cont.xml
elem_text_area.xml
elem_texto.xml
js_grid_java.xml
js_msg.xml""".split("\n")

#filenames = ["elem_rodape.xml"]

# |wiz.<nome-da-propriedade>| 
# |wiz.<nome-da-propriedade>=<valor-padr�o>| 
# |wiz[<sequ�ncia>].<nome-da-propriedade>|  
# |wiz.<nome-da-propriedade>.combo=<valor#1>[,<valor#2>,...]| 
#   exemplo: |wiz[4].Asterisco.combo={N�o[false]},Sim[true]|


print "<!ELEMENT wiz ANY>"
print "<!ELEMENT gen ANY>"
for basename in filenames:
  tipos = dict()
  filename = directory + basename
  tagname = basename.replace('_', '-').split('.')[0]
  #tagname = remove_accents(tagname)

  doc = libxml2.parseDoc(file(filename).read())
  params = set()
  for found in doc.xpathEval('//CONTENT'):
    xml = unicode(found.content, 'utf-8')
    for m in re.findall('(?u)\|wiz(?:\[\d+\])?\.([\d\w]+)(?:=([\d\w]+))?', xml):
      name = m[0].lower()
      t = tipos.setdefault(name, WizAttribute(name))
      if m[1]: t.default = m[1]
    for m in re.findall('(?u)\|wiz(?:\[\d+\])?\.([\d\w]+)\.combo=(.+?)\|', xml):
      opts = re.findall('(?u)\[(.*?)\]', m[1])
      name = m[0].lower()
      t = tipos.setdefault(name, WizAttribute(name))
      t.options = opts
      default = re.findall('(?u){.*?\[(.*?)\]}', m[1])
      if (len(default) == 1): t.default = default[0]

  print "<!ELEMENT %s EMPTY>" % tagname
  for x in tipos.values():
    x.name = x.name.encode('latin-1')
    x.default = x.default.encode('latin-1')
    x.options = [w.encode('latin-1') for w in x.options]
    if len(x.options) == 0:
      s = "<!ATTLIST %s %s CDATA \"%s\">" % (tagname, x.name, x.default)
    else:
      s = "<!ATTLIST %s %s CDATA (%s) \"%s\">" % (tagname, x.name, "|".join(x.options), x.default)
    print s


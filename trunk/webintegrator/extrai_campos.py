#!/usr/bin/env python
# -*- coding: latin1 -*-

import libxml2
import sys
import re
from elementtree import ElementTree as ET
from xml.dom.minidom import parseString

##############################################################################
##############################################################################
##############################################################################
# Extrai campos de um tipo de componente de interface do wizard
# TODO: construir DTD a partir da extraca

# |wiz.<nome-da-propriedade>| 
# |wiz.<nome-da-propriedade>=<valor-padrão>| 
# |wiz[<sequência>].<nome-da-propriedade>|  
# |wiz.<nome-da-propriedade>.combo=<valor#1>[,<valor#2>,...]| 
#   exemplo: |wiz[4].Asterisco.combo={Não[false]},Sim[true]|

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


# TODO: tratar nomes de tags e atributos com acentos.
print "<!ELEMENT wiz ANY>"
for basename in filenames:
  tipos = dict()
  filename = directory + basename
  tagname = basename.replace('_', '-').split('.')[0]

  doc = libxml2.parseDoc(file(filename).read())
  params = set()
  for found in doc.xpathEval('//CONTENT'):
    xml = found.content
    for m in re.findall('\|wiz(?:\[\d+\])?\.([\d\w]+)(=[\d\w]+)?', xml):
      name = m[0].lower()
      t = tipos.setdefault(name, WizAttribute(name))
      if m[1]: t.default = t
    for m in re.findall('\|wiz(?:\[\d+\])?\.([\d\w]+)\.combo=(.+?)\|', xml):
      opts = re.findall('\[(.*?)\]', m[1])
      name = m[0].lower()
      t = tipos.setdefault(name, WizAttribute(name))
      t.options = opts
      default = re.findall('{.*?\[(.*?)\]}', m[1])
      if (len(default) == 1): t.default = default[0]

  print "<!ELEMENT %s EMPTY>" % tagname
  for x in tipos.values():
    if len(x.options) == 0:
      print "<!ATTLIST %s %s CDATA \"%s\">" % (tagname, x.name, x.default)
    else:
      print "<!ATTLIST %s %s CDATA (%s) \"%s\">" % (tagname, x.name, "|".join(x.options), x.default)
    



##############################################################################
##############################################################################
##############################################################################
# Escreve o arquivo de layout a partir de um XML simplificado

here = """
<ROOT>
<campo-texto name="tmp.numero" obrigatorio="true" value="&lt;br/&gt;" newline="OFF"/>
<botao name="tmp.pesquisar"/>

</ROOT>
"""

def value(val, default):
  if val:
    return val
  else:
    return default

#doc = ET.parse(here)
root = ET.fromstring("<LAYOUT></LAYOUT>")
ET.SubElement(root, 'HEAD')
ET.SubElement(root, 'INDEX')
xGeneric = ET.SubElement(root, 'GENERICFIELDS')
xUser = ET.SubElement(root, 'USERFIELDS')


doc = ET.XML(here)
for tag in doc.findall("*"):
  tagName = tag.tag.replace('-', '_')
  newLine = value(tag.get('newline'), 'ON')
  elemName = tag.get('name')
  xField = ET.SubElement(xUser, 'USERFIELD', {'SEQ': 'XXX'})
  ET.SubElement(xField, 'NEWLINE').text = newLine
  ET.SubElement(xField, 'DATAFIELD').text = "USR:#elem_%s.xml" % tagName
  xParams = ET.SubElement(xField, 'PARAMETERS')
  
  for attr in tag.attrib.keys():
    if attr in ['newline', 'name']: continue
    attrname = attr.lower()
    val = tag.get(attr)
    ET.SubElement(xParams, attrname).text = val

minidoc = parseString(ET.tostring(root))
print minidoc.toprettyxml(indent="  ")

#vim:set ts=2 sw=2 softtabstop=2 expandtab ai

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
    return "%s=%s(%s)" % (self.name, self.default, str(self.options))

tipos = dict()

filename = "/var/tomcat5/webapps/sigaintranet/WEB-INF/definitions/wiz/elem_campo_texto.xml"
doc = libxml2.parseDoc(file(filename).read())
params = set()
for found in doc.xpathEval('//CONTENT'):
  xml = found.content
  for m in re.findall('\|wiz(?:\[\d+\])?\.([\d\w]+)(=[\d\w]+)?', xml):
    t = tipos.setdefault(m[0], WizAttribute(m[0]))
    if m[1]: t.default = t
  for m in re.findall('\|wiz(?:\[\d+\])?\.([\d\w]+)\.combo=(.+?)\|', xml):
    opts = re.findall('\[(.*?)\]', m[1])
    t = tipos.setdefault(m[0], WizAttribute(m[0]))
    t.options = opts
    default = re.findall('{.*?\[(.*?)\]}', m[1])
    if (len(default) == 1): t.default = default[0]

for x in tipos.values():
  print str(x)


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

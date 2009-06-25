#!/usr/bin/env python
# -*- coding: latin1 -*-

import libxml2
import sys
import re
from elementtree import ElementTree as ET
from xml.dom.minidom import parseString

import unicodedata

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


root = ET.fromstring("""<LAYOUT>
  <HEAD>
    <SCRIPT TYPE="text/javascript" SRC="/|wi.proj.id|/js/page.js">***EMPTY_TEXT***</SCRIPT>
    <META HTTP-EQUIV="pragma" CONTENT="no-cache" />
    <META HTTP-EQUIV="expires" CONTENT="0" />
    <META HTTP-EQUIV="cache-control" CONTENT="no-cache" />
    <TITLE>|titulo_projeto|</TITLE>
    <TEMPLATE>template</TEMPLATE>
    <CODE></CODE>
  </HEAD>
  <INDEX></INDEX>
  <GENERICFIELDS/>
  <USERFIELDS/>
</LAYOUT>""")

xGeneric = root.find("GENERICFIELDS")
xUser = root.find("USERFIELDS")
xCode = root.find("HEAD/CODE")
#  <INDEX>
#    <USERFIELDS SEQ="1" />
#    <USERFIELDS SEQ="2" />
#    <USERFIELDS SEQ="3" />
#    <USERFIELDS SEQ="4" />
#    <USERFIELDS SEQ="5" />
#    <USERFIELDS SEQ="8" />
#    <USERFIELDS SEQ="9" />
#    <USERFIELDS SEQ="10" />
#    <USERFIELDS SEQ="7" />
#    <USERFIELDS SEQ="6" />
#    <USERFIELDS SEQ="11" />
#    <USERFIELDS SEQ="13" />
#    <GENERICFIELDS SEQ="1" />
#  </INDEX>

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
print minidoc.toprettyxml(indent="  ", encoding="ISO-8859-1")

#vim:set ts=2 sw=2 softtabstop=2 expandtab ai

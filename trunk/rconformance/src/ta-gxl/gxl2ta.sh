#!/bin/sh
xsltproc `dirname $0`/gxl2ta.xsl $1 | sed 1d

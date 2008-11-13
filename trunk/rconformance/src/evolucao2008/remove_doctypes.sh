#!/bin/bash

for x in `find -name *.gxl`; do
  sed -i $x -e 's/^.*DOCTYPE.*$//g'
done

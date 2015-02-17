#!/bin/bash
gs \
 -sDEVICE=pdfwrite\
 -dCompatibilityLevel=1.6\
# -dPDFSETTINGS=/ebook\
 -dNOPAUSE -dQUIET\
 -dBATCH\
 -sOutputFile=$1.r $1

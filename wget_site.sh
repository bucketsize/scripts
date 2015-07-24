#!/bin/bash 

domain=$2
site=$1

echo "site: $site, domain: $domain"
wget \
     --recursive \
     --no-clobber \
     --page-requisites \
     --html-extension \
     --convert-links \
     --restrict-file-names=windows \
     --domains $domain \
     --no-parent \
         $site

#!/bin/bash
if [ -e simplefileserver ]
then
  echo "Removing old 'simplefileserver'"
  rm simplefileserver
fi
valac src/*.vala src/widgets/*.vala src/views/*.vala src/controllers/*.vala src/configs/*.vala --pkg=gtk+-3.0  --pkg=granite --pkg=gee-0.8 --pkg=libsoup-2.4 -o simplefileserver
# valac src/simpleHTTPserver.vala --pkg=gtk+-3.0  --pkg=granite --pkg=gee-0.8 --pkg=libsoup-2.4 -o simplefileserver
if [ -e simplefileserver ]
then
  echo "####################################"
  echo "      Successfully complied!!      "
  echo "####################################"
  ./simplefileserver
else
  echo "------------------------------------"
  echo "       Compilation failed...        "
  echo "------------------------------------"
fi

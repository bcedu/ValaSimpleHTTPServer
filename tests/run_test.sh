#!/bin/bash
if [ -e test ]
then
  echo "Removing old 'test'"
  rm test
fi
valac --main=main test.vala *_tests.vala ../src/*.vala ../src/widgets/*.vala ../src/views/*.vala ../src/controllers/*.vala ../src/configs/*.vala --pkg=gtk+-3.0  --pkg=granite --pkg=gee-0.8 --pkg=libsoup-2.4 -o test
if [ -e test ]
then
  echo "####################################"
  echo "   Tests successfully complied!!    "
  echo "####################################"
  COLOR='\033[0;33m'
  NC='\033[0m' # No Color
  printf "${COLOR}Running all tests:${NC}\n"
  OUTPUT="$(./test)"
  printf "${COLOR}${OUTPUT}${NC}\n"
  rm test
else
  echo "------------------------------------"
  echo "    Tests compilation failed...     "
  echo "------------------------------------"
fi

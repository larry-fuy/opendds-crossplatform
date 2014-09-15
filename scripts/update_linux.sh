#!/bin/sh
# Update OpenDDS
# Readme : http://www.dre.vanderbilt.edu/~schmidt/DOC_ROOT/DDS/docs/INSTALL
cd /opt
if [ -d trunk ]; then
    cd trunk && svn up
else 
   svn co svn://svn.dre.vanderbilt.edu/DOC/DDS/trunk
fi
# run script to automatically download the TAO/ACE and compile
cd trunk 
./configure
make
chmod +x ./setenv.sh && ./setenv.sh

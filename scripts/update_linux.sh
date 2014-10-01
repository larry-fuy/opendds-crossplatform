#!/bin/sh
# Update OpenDDS
touch build_dds_linux.log
exec 1>build_dds_linux.log

if [ -d /opt/trunk ]; then
    cd /opt/trunk && svn up
else 
    # no source code (in some cases) then dowload 
    # http://www.dre.vanderbilt.edu/~schmidt/DOC_ROOT/DDS/docs/INSTALL
   cd /opt
   svn co svn://svn.dre.vanderbilt.edu/DOC/DDS/trunk
fi
# run script to automatically download the TAO/ACE and compile
cd /opt/trunk 
./configure
make
chmod +x ./setenv.sh && ./setenv.sh

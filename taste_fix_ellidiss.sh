#!/bin/bash


BASESVN=/home/assert/tool-src

sudo rm -rf /opt/Ellidiss-TASTE-linux/* 
sudo cp -a /home/assert/tool-src/ellidiss/TASTE-linux/* /opt/Ellidiss-TASTE-linux/
for i in IVConfig.ini TASTE_IV_Properties.aadl TASTE_DV_Properties.aadl ; do
    sudo cp -a /home/assert/tool-src/misc/ellidiss/$i /opt/Ellidiss-TASTE-linux/config/
done
cat /opt/Ellidiss-TASTE-linux/config/IVConfig.ini | sed 's,./bin/asn2aadl.exe,/opt/DMT/asn2aadlPlus/asn2aadlPlus.py,' > /tmp/patched.$$ && sudo mv /tmp/patched.$$ /opt/Ellidiss-TASTE-linux/config/IVConfig.ini

# Fix path to Ellidiss tools, if missing
if ! grep Ellidi /home/assert/assert_env.sh > /dev/null ; then
    { cat /home/assert/assert_env.sh ; echo 'export PATH=$PATH:/opt/Ellidiss-TASTE-linux/' ; } > /tmp/env.$$ && mv /tmp/env.$$ /home/assert/assert_env.sh
fi



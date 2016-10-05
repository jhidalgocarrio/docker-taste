#!/bin/bash

export LANG=C
export WP44=`/bin/ls /opt/ | grep ^DMT 2>/dev/null | tail -1`
if [ "$WP44" == "" ] ; then
        echo You must install the ASSERT toolchain under /opt/DMT-...
        echo Download it from http://www.semantix.gr/assert/
        #exit 1
fi

export WP44="/opt/$WP44"
export DMT=/home/assert/tool-inst/share/
export OCARINAPATH=`/bin/ls /opt/ | grep ^ocarina-2 2>/dev/null | tail -1`
if [ "${OCARINAPATH}" == "" ] ; then
        echo You must install ocarina under /opt/
        echo Download it from http://ocarina.enst.fr/
        #exit 1
fi
export OCARINAPATH="/opt/${OCARINAPATH}"
export PATH=/usr/lib/ccache:/usr/gnat/bin:/opt/gnatforleon-2.1.1/bin:${OCARINAPATH}/bin:$PATH
export ASN1SCC=$DMT/asn1scc/asn1.exe
export LM_LICENSE_FILE="none"

export PATH=$DMT/OG:$DMT/aadl2glueC:$DMT/asn2aadlPlus:$DMT/asn1scc:$DMT/asn2dataModel:$PATH

# GUIs and Python bridges use message queues for communication - TMs and TCs
# When a TM queue is full, error messages appear (that is, sending a TM to a GUI/Python which is not running)
# To suppress these errors:

# export ASSERT_IGNORE_GUI_ERRORS=1
export ASSERT_IGNORE_PYTHON_ERRORS=1

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/i386-linux-gnu
export PATH=$PATH:/opt/mast/ ; export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/mast/lib

export PATH=$PATH:/opt/rtems-4.11/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rtems-4.11/lib
export RTEMS_MAKEFILE_PATH_LEON=/opt/rtems-4.11/sparc-rtems4.11/leon2

export PATH=$PATH:/opt/Ellidiss-TASTE-linux
export PATH=$PATH:/opt/qemu-leon2/bin
export PATH=$PATH:/home/assert/tool-inst/bin
export PATH=/home/assert/.local/bin/:$PATH

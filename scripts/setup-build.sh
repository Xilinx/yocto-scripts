#!/bin/bash

#########################################################
# Fetches all the source needed to build meta-xilinx layer
########################################################

SCRIPTDIR=$(dirname $(readlink -f "$0"))
YOCTOBRANCH=""

function setup_build()
{

    [ -n "$YOCTOBRANCH" ] || YOCTOBRANCH=("fido" "dizzy" "daisy" "dora" "master")

    for YOCTOBRANCH in ${YOCTOBRANCH[@]}; do
        mkdir -p "$SCRIPTDIR/$YOCTOBRANCH"
        cd "$SCRIPTDIR/$YOCTOBRANCH"

        echo -ne "Getting sources for $YOCTOBRANCH... "
        repo init -u git://gitenterprise/Yocto/yocto-manifests.git \
                  -m meta-xilinx.xml -b $YOCTOBRANCH > /dev/null 2>&1
        repo sync -j 16 > /dev/null 2>&1
        repo start $YOCTOBRANCH --all
        if [ $? -eq 0 ];then
            echo "done"
        else
            echo "failed"
            continue
        fi

    done
}


function show_help()
{
echo 'YOCTO meta-xilinx setup script to fetch all sources for build'
echo 'Usage: compile [options]'
echo '    -h | --help     Display usage help (this text) and exit'
echo '    -b | --branches List of Yocto branches to fetch, default is all suppported branches'
}

TEMP=`getopt -o hb: --long help,branches: -- "$@"`

if [ $? != 0 ] ; then show_help >&2 ; exit 0 ; fi

eval set -- "$TEMP"
BUILDDIR=""

while [ $# -gt 0 ]; do
    case "$1" in
        -h | --help ) show_help; exit 0 ;;
        -b | --branches ) YOCTOBRANCH="$2 $YOCTOBRANCH"; shift 2 ;;
        -- ) shift; break ;;
        * ) break ;;
    esac
done

setup_build
exit 0

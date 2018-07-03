#!/bin/sh
OLDDUMP=broken.svndump
REPO=$(pwd)/fixed
REPURL=$(npx file-url-cli ${REPO})
WD=${REPO}.d
DUMP=${REPO}.svndump

set -x
perl ../svn-dump-reloc.pl ../brokenreloc.json < ${OLDDUMP} > ${DUMP}
diff ${DUMP} fixed-expect.svndump || ( echo 'Did not match expected'; exit 1)
if [ -d ${REPO} ];
then
    echo err: ${REPO} already exists, not recreating
    exit 1
fi

svnadmin create ${REPO}
svnadmin load -q < ${DUMP} ${REPO}
if [ -d ${WD} ];
then
    echo err: ${WD} exists, not checking out
    exit 1
fi
svn co ${REPURL} ${WD}




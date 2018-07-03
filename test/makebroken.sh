#!/bin/sh
REPO=$(pwd)/broken
REPURL=$(npx file-url-cli ${REPO})
WD=${REPO}.d
DUMP=${REPO}.svndump

if [ -d ${REPO} ];
then
    echo err: ${REPO} already exists
    exit 1
fi

set -x
svnadmin create ${REPO}
svn mkdir -m 'square one' --parents ${REPURL}/icu/trunk
svn mkdir -m 'setup' --parents ${REPURL}/icu/branches/tkeep
svn cp    -m 'branch' ${REPURL}/icu/trunk ${REPURL}/icu/branches/tkeep/10804
svn del   -m 'oops r35592' ${REPURL}/icu/trunk ${REPURL}/icu/branches/tkeep/10804
svn cp    -m 'fix r35593' ${REPURL}/icu/trunk@3 ${REPURL}/icu/trunk
## TODO: reorg?
svn mkdir -m 'reorg' --parents ${REPURL}/trunk ${REPURL}/branches
svn cp -m 'reorg2' ${REPURL}/icu/trunk ${REPURL}/trunk/icu


svnadmin dump ${REPO} > ${DUMP} && wc -l ${DUMP}

svn co ${REPURL} ${WD}
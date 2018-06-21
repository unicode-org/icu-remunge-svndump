#!/bin/sh
set -x
# rm -rf reposbis reposbis.dump
rm -rf reposbis reposbis.svndump
perl ./svn-dump-reloc.pl reloc.json < test/repos.svndump > reposbis.svndump
svnadmin create ./reposbis
svnadmin load ./reposbis  < reposbis.svndump || exit 1
rm -rf workbis
svn co file://$(pwd)/reposbis ./workbis


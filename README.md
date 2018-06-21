# icu-remunge-svndump

for munging ICU's [svndump](http://svn.apache.org/repos/asf/subversion/trunk/notes/dump-load-format.txt)

- usage:

        svnadmin create /repos/icu2
        
        svnadmin dump /repos/icu  | perl svn-dump-reloc.pl icureloc.json | svnadmin load /repos/icu2
        
        # now convert to git, etc


- tags generated with:

    $ svn list ^/icu/tags ^/icu4j/tags | sort | uniq | sed -e 's%.*%  "/tags/&",%' 


### LICENSE

Major portions from Salvador Fandiño García http://search.cpan.org/~salva/SVN-DumpReloc-0.02/

    COPYRIGHT AND LICENCE

    Copyright (C) 2007-2008 by Qindel Formacion y Servicios S.L.

    Permission is hereby granted, free of charge, to any person
    obtaining a copy of this software and associated documentation files
    (the "Software"), to deal in the Software without restriction,
    including without limitation the rights to use, copy, modify, merge,
    publish, distribute, sublicense, and/or sell copies of the Software,
    and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
    BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
    ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.




part of ICU tools, see [LICENSE](./LICENSE)
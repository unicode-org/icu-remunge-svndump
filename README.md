# icu-remunge-svndump

for munging ICU's [svndump](http://svn.apache.org/repos/asf/subversion/trunk/notes/dump-load-format.txt)

## Theory

Pipeline:

- `fs.readableStream('icu.svndump')`
- `SvnDumpReader` - convert raw to structure (object stream):

```json
{
    "headers": {
        "Node-path": "a/tags",
        "Node-kind": "dir",
        "Node-action": "add",
        "Prop-content-length": "10",
        "Text-content-length": "10",
        "Content-length": "20"
    },
    "props": {
        "svn:author": "srl",
        "svn:date": "2018-06-12T20:32:41.873637Z"
    },
    "data": "this is b\n"
}
```
- `SvnPathFilter` - take in structured stream, fix paths, add/omit entries per config
- `SvnDumpWriter` - convert structured stream back to svn text dump 
- `fs.writableStream('icu-mod.svndump')` ( and then on to svn2git etc. )


- tags generated with:

    $ svn list ^/icu/tags ^/icu4j/tags | sort | uniq | sed -e 's%.*%  "/tags/&",%' 


### LICENSE

part of ICU tools, see [LICENSE](./LICENSE)
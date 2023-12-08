# icu-remunge-svndump

for munging ICU's [svndump](http://svn.apache.org/repos/asf/subversion/trunk/notes/dump-load-format.txt)

- usage:

        svnadmin create /repos/icu2

        svnadmin dump /repos/icu  | perl svn-dump-reloc.pl icureloc.json | svnadmin load /repos/icu2

        # now convert to git, etc


- tags generated with:

    $ svn list ^/icu/tags ^/icu4j/tags | sort | uniq | sed -e 's%.*%  "/tags/&",%'

- config file format

    - `map:`

        this is a series of regexes from old to new. they will be applied to all paths.

        ```json
        {
            "map": [
                [ "^(icu4j|tools)\\/(trunk)$", "\"$2\\/$1\""],
                [ "^(icu)\\/(trunk)\\/(.+)$", "\"$2\\/icu4c\\/$3\""]
            ]
        }
        ```
    - `r1:`

        r1 is special and can have some `mkdir` lines that will be created at r1 and will be protected against re-creation.

        ```json
        {
            "r1": {
                "mkdir": [
                    "/trunk",
                    "/branches",
                    "/tags"
                ]
            }
        }
        ```

        In theory the following rules could also be a part of r1, but thi has not been teted.

    - `r*:` there can be rules for each revision. The two supported rules are:
        - `map-action` - map one action to another. The following example maps `delete` to `change` for two specified paths. (I have only tested with one path, but it should work™).

        ```json
        "map-action": {
            "delete": {
                "icu/trunk": "change",
                "icu/tags": "change"
            }
        }
        ```

        - `map-Node-path` - map one Node-path to another. This maps `/icu/trunk` to `/ignore-me`.

        ```json
        "map-Node-path": {
            "icu/trunk": "ignore-me"
        }
        ```

### License

Copyright © 2016-2023 Unicode, Inc. Unicode and the Unicode Logo are registered trademarks of Unicode, Inc. in the United States and other countries.

The project is released under [LICENSE](./LICENSE).

A CLA is required to contribute to this project - please refer to the [CONTRIBUTING.md](https://github.com/unicode-org/.github/blob/main/.github/CONTRIBUTING.md) file (or start a Pull Request) for more information.


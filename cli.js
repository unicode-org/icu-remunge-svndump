// Copyright © 1991-2018 Unicode, Inc. All rights reserved.
// Distributed under the Terms of Use in http://www.unicode.org/copyright.html.

const minimist = require('minimist');

class CLI {

    constructor(argv) {
        this._argv = argv;
        this.argv = minimist(argv.slice(2), {

        });
    }

    async run() {
        const argv = this.argv;

        
    }
}

module.exports = CLI;

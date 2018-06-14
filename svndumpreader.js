// Copyright © 1991-2018 Unicode, Inc. All rights reserved.
// Distributed under the Terms of Use in http://www.unicode.org/copyright.html.

const { Duplex } = require('stream');
const fs = require('fs');

class SvnDumpReader extends Duplex {
    constructor() {
        super({
            readableObjectMode: true,
            writableHighWaterMark: 3
        });
        this.linebuf = '';
        this.rowbuf = [];
        this.headers = null;

        this.on('pipe', (fromWhat) => {
            // setTimeout(()=>{}, 3000);
            // console.log('src encoding', fromWhat.encoding);
        });
    }

    /**
     * Read one line if available. null if not.
     * return '' on empty line.
     */
    readOneLine() {
        if(this.linebuf.length === 0) return;

        const endLine = this.linebuf.indexOf('\n');
        if(endLine<0) return;
        const r = this.linebuf.substring(0, endLine);
        this.linebuf = this.linebuf.substring(endLine+1);
        return r;
    }

    /**
     * Read a bunch of headers (pushing in rowbuf) until '' is found.
     * Return: the rowbuf buffer if OK (including '') else falsy
     */
    readHeaders() {
        if(this.rowbuf[this.rowbuf.length-1] === '') {
            return this.rowbuf; // todo: slice?
        }
        do {
            const r = this.readOneLine();
            if(r === '') {
                this.rowbuf.push(r);
                return this.rowbuf;
            } else if(!r) {
                return;
            } else {
                this.rowbuf.push(r);
            }
        } while(this.rowbuf[this.rowbuf.length-1] !== '');
    }

    /**
     * push one object
     */
    readOne() {
        if(!this.headers) {
            this.headers = this.readHeaders();
            if(this.headers) {
                this.rowbuf = [];
            }
        }
        if(!this.headers) return; // no headers yet.

        this.push({headers: this.headers});
        // this.push(r);
    }

    /**
     * Start fetching from string
     */
    _read() {
        // console.log('read');
        this.readOne();
    }

    _write(chunk, enc) {
        if(enc && enc !== 'buffer') {
            chunk = chunk.toString(enc);
        }
        console.log(`_write(${chunk.length})`);
        this.linebuf += chunk; // just keep appending
        this.readOne();
    }

    _writev() {
        throw Error('not imp yet: writev');
    }

    _final() {
        console.log('final');

    }
}

module.exports = SvnDumpReader;

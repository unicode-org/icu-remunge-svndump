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
        this.objbuf = [];
        this.linebuf = '';
        this.rowbuf = [];
        this.headers = null;
        this.pushok = false;
        this.closed = false;

        this.on('pipe', (fromWhat) => {
            // setTimeout(()=>{}, 3000);
            // console.log('src encoding', fromWhat.encoding);
        });

        // this.on('close', () => {
        //     this.closed = true;
        //     // this.readOne(); // try once more?
        // });
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

    tryPush() {
        if(this.pushok && this.objbuf.length > 0) {
            const o = this.objbuf.shift();
            this.pushok = this.push(o);
            // console.dir({shift: o});
            console.log('prepush', this.pushok, 'queue', this.objbuf.length);
        } else {
            console.log('nopush', this.pushok, 'queue', this.objbuf.length);
        }
    }

    /**
     * push one object
     */
    readOne() {
        // Try once..
        // try to read another 
        if(!this.headers) {
            this.headers = this.readHeaders();
            if(this.headers) {
                this.rowbuf = [];
            }
        }
        if(this.headers) {
            // push onto the object queue
            const oo = {headers: this.headers};
            // console.dir({push: oo});
            this.objbuf.push(oo);
            this.headers = null; // reset
            console.log('objbuf++', this.objbuf.length);
        }
        this.tryPush();
        if(!this.objbuf.length === 0 && this.closed) {
            // this.emit('close');
            console.log('@@ Time to close');
        } else {
            console.log('queue', this.objbuf.length, 'closed', this.closed);
        }
    }

    /**
     * Start fetching from string
     */
    _read() {
        console.log('_read');
        // they asked us to read, so
        this.pushok = true;
        // console.log('read');
        this.readOne();
    }

    _write(chunk, enc, cb) {
        if(enc && enc !== 'buffer') {
            chunk = chunk.toString(enc);
        }
        console.log(`_write(${chunk.length})`);
        this.linebuf += chunk; // just keep appending
        this.readOne();
        cb();
    }

    _writev() {
        throw Error('not imp yet: writev');
    }

    _final(cb) {
        console.log('final');
        this.closed = true;
        cb();
    }
}

module.exports = SvnDumpReader;

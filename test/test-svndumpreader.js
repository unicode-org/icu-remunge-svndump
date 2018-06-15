// Copyright © 1991-2018 Unicode, Inc. All rights reserved.
// Distributed under the Terms of Use in http://www.unicode.org/copyright.html.

const SVNDumpReader = require('../index').svndumpreader;
const t = require('tap');
const fs = require('fs');

// t.test('basic', t => {
//     const f = new SVNDumpReader();
//     t.ok(f);

//     t.end();
// });


t.test('readok', t => {
    const fin = fs.createReadStream('./test/trivial.svndump');
    const f = new SVNDumpReader();
    fin.pipe(f,{});
    t.ok(f);
    f.on('readable', () => console.log('readable'));
    f.on('error', (err) => console.error(err));
    f.on('end', () => t.end());
    f.on('data', (chunk) => console.dir(Object.keys(chunk.headers).length, {depth: Infinity, color: true}));
    // setInterval(() => {}, 3000);
});
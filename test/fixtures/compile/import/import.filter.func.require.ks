extern console

import '../export/export.but.all.ks' for Foobar

import '../export/export.filter.func.require.ks'(Foobar)

console.log(`\(foobar('foobar'))`)

const x = new Foobar()

console.log(`\(foobar(x).toString())`)

export Foobar, foobar
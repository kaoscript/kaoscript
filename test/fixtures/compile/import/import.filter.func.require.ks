extern console

import '../export/export.but.all.ks' for Foobar

import '../export/export.filter.func.require.ks'(Foobar)

console.log(`\(foobar('foobar'))`)

var x = Foobar.new()

console.log(`\(foobar(x).toString())`)

export Foobar, foobar
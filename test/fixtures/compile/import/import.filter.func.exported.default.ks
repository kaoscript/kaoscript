extern console

import '../export/export.filter.func.exported.default.ks'

console.log(`\(qux('foobar'))`)

var x = foobar()

console.log(`\(x.toString())`)

console.log(`\(qux(x).toString())`)
extern console

class Foobar {
	toString(): String => 'foobar'
}

import '../export/export.filter.func.exported.sealed.ks'

console.log(`\(qux('foobar'))`)

var x = foobar()

console.log(`\(x.toString())`)

console.log(`\(qux(x).toString())`)
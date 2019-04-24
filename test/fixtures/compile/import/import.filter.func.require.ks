extern console

class Foobar {
	toString(): String => 'foobar'
}

import '../export/export.filter.func.require.ks'(Foobar)

console.log(`\(foobar('foobar'))`)

const x = new Foobar()

console.log(`\(foobar(x).toString())`)
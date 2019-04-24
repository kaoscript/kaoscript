extern console

class Foobar {
	toString(): String => 'foobar'
}

import '../export/export.filter.func.extern.ks'

console.log(`\(foobar('foobar'))`)

const x = new Foobar()

console.log(`\(x.toString())`)

console.log(`\(foobar(x).toString())`)
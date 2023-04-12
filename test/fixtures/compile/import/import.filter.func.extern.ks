extern console

class Foobar {
	toString(): String => 'foobar'
}

import '../export/export.filter.func.extern.ks'

console.log(`\(foobar('foobar'))`)

var x = Foobar.new()

console.log(`\(x.toString())`)

console.log(`\(foobar(x).toString())`)
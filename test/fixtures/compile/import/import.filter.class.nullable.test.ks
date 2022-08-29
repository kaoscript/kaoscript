extern console

import '../export/export.filter.class.nullable.ks'

var q = new Qux()

if var foo ?= q.foo() {
	console.log(`\(foo.toString())`)
}
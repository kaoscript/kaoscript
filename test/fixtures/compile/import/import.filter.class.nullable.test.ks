extern console

import '../export/export.filter.class.nullable.ks'

var q = Qux.new()

if var foo ?= q.foo() {
	console.log(`\(foo.toString())`)
}
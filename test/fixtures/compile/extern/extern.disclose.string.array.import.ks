extern console

import './extern.disclose.string.array.default.ks'

func foo(value: String) {
	console.log(`\(value.trim())`)

	var list = value.split(',')

	console.log(`\(list[0])`)
}
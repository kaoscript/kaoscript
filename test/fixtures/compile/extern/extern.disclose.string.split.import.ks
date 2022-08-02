extern console

import './extern.disclose.default'

func foo(value: String) {
	console.log(`\(value.trim())`)

	var list = value.split(',')

	console.log(`\(list[0])`)
}
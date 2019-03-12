extern console

import './extern.disclose.string.array.default'

func foo(value: String) {
	console.log(`\(value.trim())`)

	const list = value.split(',')

	console.log(`\(list[0])`)
}
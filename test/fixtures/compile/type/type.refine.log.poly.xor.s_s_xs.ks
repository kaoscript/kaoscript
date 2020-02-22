extern console

import '../_/_boolean'
import '../_/_number'
import '../_/_string'

func test(x): Boolean => true

func foobar() {
	let x = false
	let y = false

	if test('1') ^^ test('2') ^^ test(x = '3') {
		console.log(x.toInt())
		console.log(y.toInt())
	}
	else {
		console.log(x.toInt())
		console.log(y.toInt())
	}

	console.log(x.toInt())
	console.log(y.toInt())
}
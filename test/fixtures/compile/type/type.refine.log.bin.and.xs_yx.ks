extern console

import '../_/_boolean'
import '../_/_number'
import '../_/_string'

func test(x): Boolean => true

func foobar() {
	let x = false
	let y = false

	if test(x = '1') && test(y = x) {
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
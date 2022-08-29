extern console

import '../_/_boolean'
import '../_/_number'
import '../_/_string'

func test(x): Boolean => true

func foobar() {
	var dyn x = false
	var dyn y = false

	if test('1') ^^ test(x <- '2') {
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
#![libstd(off)]

extern console

import '../_/_boolean.ks'
import '../_/_number.ks'
import '../_/_string.ks'

func test(x): Boolean => true

func foobar() {
	var dyn x = false
	var dyn y = false

	if test('1') && test(x <- '2') && test(x <- 3) {
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
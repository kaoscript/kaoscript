#![libstd(off)]

extern console

import '../_/_boolean.ks'
import '../_/_number.ks'
import '../_/_string.ks'

func test(x): Boolean => true

func foobar() {
	var dyn x = false
	var dyn y = false

	if test(x <- '1') && test(y <- 2) {
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
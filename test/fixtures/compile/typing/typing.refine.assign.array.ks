#![libstd(off)]

extern console

import '../_/_array.ks'

func foo(mut x, values) {
	if x is Array {
		console.log(x.last())

		if values[x <- x.last()] {
			console.log(x.last())
		}
		else {
			console.log(x.last())
		}
	}
	else {
		console.log(x.last())
	}
}
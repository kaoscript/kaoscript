extern console, qux

import '../_/_array'

func foo(mut x) {
	if x is Array {
		console.log(x.last())

		if qux[x <- x.last()] {
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
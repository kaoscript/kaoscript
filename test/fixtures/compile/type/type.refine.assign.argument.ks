extern console, qux

import '../_/_array'

func foo(x) {
	if x is Array {
		if qux(x = x.last()) {
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
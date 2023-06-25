extern console

import '../_/_string.ks'

func foo(x) {
	if x is String && x.toInt() == 42 {
		console.log(`\(x)`)
	}
	else {
		console.log(`\(x)`)
	}
}
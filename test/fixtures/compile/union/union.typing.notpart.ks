#![libstd(off)]

import {
	'../_/_number.ks'
	'../_/_string.ks'
}

func foo(x: String | Number) {
	if x is Array {
		return x.lower()
	}
	else {
		return x
	}
}
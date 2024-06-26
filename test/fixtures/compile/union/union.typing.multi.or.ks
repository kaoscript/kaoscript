#![libstd(off)]

import {
	'../_/_number.ks'
	'../_/_string.ks'
}

func foo(x: String | Number | Array) {
	if x is String || x is Number {
		return x.toFloat()
	}
	else {
		return x
	}
}
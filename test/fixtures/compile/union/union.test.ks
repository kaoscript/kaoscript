#![libstd(off)]

import {
	'../_/_number.ks'
	'../_/_string.ks'
}

func foo(x: String | Number) {
	if x.toFloat() == 42 {
	}
}
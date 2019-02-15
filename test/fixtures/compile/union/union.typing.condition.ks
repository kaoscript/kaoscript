import {
	'../_/_number.ks'
	'../_/_string.ks'
}

func foo(x: String | Number) {
	if x is String && x.lower() == 'foobar' {
		return x.lower()
	}
	else {
		return x
	}
}
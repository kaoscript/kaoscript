import {
	'./_number.ks'
	'./_string.ks'
}

func foo(x: String | Number) {
	return 42 - x.toFloat()
}

func bar(x: String | Number, y: String | Number) {
	return x.toFloat() - y.toFloat()
}
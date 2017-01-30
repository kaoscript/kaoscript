#![runtime(type(alias="yourtype"))]

func foo(x, y) {
	if x is String {
		return x.toInt()
	}
	else {
		return y
	}
}
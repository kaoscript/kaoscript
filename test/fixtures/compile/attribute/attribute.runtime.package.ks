#![runtime(package="yourpackage")]

func foo(x, y) {
	if x is String {
		return x
	}
	else {
		return y
	}
}
#![runtime(prefix='KS')]

func foo(x, y) {
	return x + y
}

func bar(x, y) {
	if x is String {
		return x
	}
	else {
		return y
	}
}
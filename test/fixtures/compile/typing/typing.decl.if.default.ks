func foo(x: Boolean): String {
	var dyn y = null

	if x {
		y = bar()
	}

	if y != null {
		return y.z.toString()
	}
	else {
		return ''
	}
}

func bar() => {
	z: 42
}
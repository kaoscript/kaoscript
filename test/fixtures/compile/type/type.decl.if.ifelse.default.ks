func foo(x: Boolean): String {
	var dyn y

	if x {
		y = '42 * x'
	}
	else {
		y = '24 * x'
	}

	return `\(y)`
}
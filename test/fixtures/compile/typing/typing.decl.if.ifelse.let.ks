func foo(x: Boolean): String {
	var dyn y

	if x {
		var dyn y

		y = '42 * x'
	}
	else {
		var dyn y

		y = '24 * x'
	}

	return `\(y)`
}
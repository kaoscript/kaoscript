func foo(x: Boolean): String {
	let y

	if x {
		y = '42 * x'
	}
	else {
		y = '24 * x'
	}

	return `\(y)`
}
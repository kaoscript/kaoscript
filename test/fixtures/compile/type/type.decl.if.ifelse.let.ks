func foo(x: Boolean): String {
	let y

	if x {
		let y

		y = '42 * x'
	}
	else {
		let y

		y = '24 * x'
	}

	return `\(y)`
}
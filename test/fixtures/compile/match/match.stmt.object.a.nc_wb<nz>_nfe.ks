func foobar(value) {
	match value {
		with var {qux % n} 			=> echo(`qux: \(n)`)
	}
}
func foobar(value) {
	match value {
		{foo: 1}	with {qux % n: Number} 	=> echo(`qux: \(n)`)
	}
}
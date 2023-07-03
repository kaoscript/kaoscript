func foobar(value) {
	match value {
		{foo: 1}	with var {qux % n: Number} 	=> echo(`qux: \(n)`)
	}
}
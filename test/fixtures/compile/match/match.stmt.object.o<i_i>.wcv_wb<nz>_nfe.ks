func foobar(value: {foo: Number, qux: Number}) {
	match value {
		{foo: 1}	with var {qux % n} 			=> echo(`qux: \(n)`)
	}
}
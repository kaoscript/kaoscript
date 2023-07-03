func foobar(value: Object) {
	match value {
		{foo: 1}	with var {qux % n} 			=> echo(`qux: \(n)`)
	}
}
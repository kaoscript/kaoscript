func foobar(value: Object) {
	match value {
		{foo: 1}	with {qux % n} 			=> echo(`qux: \(n)`)
	}
}
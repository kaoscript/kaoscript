struct Foobar {
	foo: Number
	qux: Number
}

func foobar(value: Foobar) {
	match value {
		{foo: 1}	with {qux % n} 			=> echo(`qux: \(n)`)
	}
}
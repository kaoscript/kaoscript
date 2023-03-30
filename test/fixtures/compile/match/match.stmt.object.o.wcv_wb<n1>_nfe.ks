func foobar(value: Object) {
	match value {
		{foo: 1}	with {foo} 			=> echo(`foo: \(foo)`)
	}
}
func foobar(value: Object) {
	match value {
		{foo: 1}	with var {foo} 			=> echo(`foo: \(foo)`)
	}
}
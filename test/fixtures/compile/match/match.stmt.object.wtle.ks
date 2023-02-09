func foobar(value: Array) {
	match value {
		{foo: 1}	with {qux: n} 			=> echo(`qux: \(n)`)
		{foo: 1} 							=> echo('foo: 1')
		{foo}								=> echo('has foo')
		{qux}								=> echo('has qux')
					when value.bar() == 0	=> echo('bar() == 0')
		else								=> echo('oops!')
	}
}
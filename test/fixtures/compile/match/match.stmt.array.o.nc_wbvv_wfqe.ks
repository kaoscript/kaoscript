func foobar(pair: Object) {
	match pair {
		with var [x, y]	when x == y			=> echo('These are twins')
	}
}
func foobar(pair: Object) {
	match pair {
		with [x, y]	when x == y			=> echo('These are twins')
	}
}
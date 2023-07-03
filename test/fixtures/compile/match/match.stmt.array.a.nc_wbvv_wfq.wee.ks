func foobar(pair) {
	match pair {
		with var [x, y]	when x == y			=> echo('These are twins')
		else							=> echo('No correlation...')
	}
}
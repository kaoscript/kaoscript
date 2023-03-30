func foobar(pair) {
	match pair {
		with [x, y]	when x == y			=> echo('These are twins')
		with [x, y]	when x + y == 0		=> echo('Antimatter, kaboom!')
	}
}
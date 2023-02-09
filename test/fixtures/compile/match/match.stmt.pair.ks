func foobar(pair) {
	match pair {
		with [x, y]	when x == y			=> echo('These are twins')
		with [x, y]	when x + y == 0		=> echo('Antimatter, kaboom!')
		with [x, _]	when x % 2 == 1		=> echo('The first one is odd')
		else							=> echo('No correlation...')
	}
}
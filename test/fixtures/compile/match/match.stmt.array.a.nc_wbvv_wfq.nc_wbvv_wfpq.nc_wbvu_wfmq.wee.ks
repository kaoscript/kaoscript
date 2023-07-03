func foobar(pair) {
	match pair {
		with var [x, y]	when x == y			=> echo('These are twins')
		with var [x, y]	when x + y == 0		=> echo('Antimatter, kaboom!')
		with var [x, _]	when x % 2 == 1		=> echo('The first one is odd')
		else							=> echo('No correlation...')
	}
}
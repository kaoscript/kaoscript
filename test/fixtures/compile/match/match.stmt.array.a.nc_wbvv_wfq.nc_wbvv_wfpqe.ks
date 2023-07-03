func foobar(pair) {
	match pair {
		with var [x, y]	when x == y			=> echo('These are twins')
		with var [x, y]	when x + y == 0		=> echo('Antimatter, kaboom!')
	}
}
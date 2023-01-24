block top {
	echo('entering block')

	for var i from 1 to 10 {
		for var j from 1 to 10 {
			echo(`looping \(i).\(j)`)

			if i == 5 {
				// let's leave the block (and the loops)
				break top
			}
		}
	}

	echo('still in block') // never printed
}
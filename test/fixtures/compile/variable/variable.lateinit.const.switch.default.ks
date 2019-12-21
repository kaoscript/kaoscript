func foobar(x) {
	lateinit const value

	switch x {
		1, 2, 3 => {
			value = 0
		}
		4 => {
			value = 1
		}
		=> {
			value = -1
		}
	}

	return value
}
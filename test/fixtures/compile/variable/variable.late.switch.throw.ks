func foobar(x) ~ Error {
	var late value

	switch x {
		1, 2, 3 => {
			value = 0
		}
		4 => {
			value = 1
		}
		=> {
			throw new Error()
		}
	}

	return value
}
func foobar(x) ~ Error {
	var late value

	match x {
		1 | 2 | 3 {
			value = 0
		}
		4 {
			value = 1
		}
		else {
			throw new Error()
		}
	}

	return value
}
func foobar(x, y) {
	lateinit const z

	if x == 0 {
		z = 1
	}
	else if y == 0 {
	}
	else if x == 1 && y == 1 {
		z = 2
	}
	else {
		z = 0
	}

	return z
}
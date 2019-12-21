func foobar(): Number {
	lateinit let z

	z = 0

	for const i from 1 to 10 {
		z = i
	}

	return z
}
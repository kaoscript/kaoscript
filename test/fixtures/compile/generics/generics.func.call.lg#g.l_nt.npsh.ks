type Card = {
	rank: Number
}

func foobar<T>(values: T[]): T {
	return values[0]
}

func quxbaz() {
	var values = []

	foobar(values)
}
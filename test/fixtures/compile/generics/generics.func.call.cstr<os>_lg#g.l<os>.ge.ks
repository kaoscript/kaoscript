type Named = {
	name: String
}

func foobar<T is Named>(values: T[]): T {
	return values[0]
}

func quxbaz(values: Named[]) {
	var value = foobar(values)

	corge(value)
}

func corge(value: Named) {
}
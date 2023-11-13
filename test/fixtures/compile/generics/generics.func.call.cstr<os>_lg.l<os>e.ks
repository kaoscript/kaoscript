type Named = {
	name: String
}

func foobar<T is Named>(values: T[]) {
}

func quxbaz(values: Named[]) {
	foobar(values)
}
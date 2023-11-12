func foobar<T>(value: T): { value: T } {
	return {
		value
	}
}

func quxbaz(value: String): { value: String } {
	return foobar(value)
}
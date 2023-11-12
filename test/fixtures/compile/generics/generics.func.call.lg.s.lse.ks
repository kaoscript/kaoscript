func foobar<T>(value: T): T[] {
	return [value, value]
}

func quxbaz(value: String): String[] {
	return foobar(value)
}
func foobar(functions: Array<(x: String): String>): Array<String> {
	return [fn(42) for const fn in functions]
}
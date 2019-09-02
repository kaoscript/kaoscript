func foobar(functions: Array<(x: String): String>): Array<String> {
	return [fn('foobar') for const fn in functions]
}
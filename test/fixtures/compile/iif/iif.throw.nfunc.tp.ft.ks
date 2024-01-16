func foobar(test, resolve: (): String) ~ Error {
	var value = if test() {
		set resolve()
	}
	else {
		throw Error.new()
	}

	echo(`\(value)`)
}
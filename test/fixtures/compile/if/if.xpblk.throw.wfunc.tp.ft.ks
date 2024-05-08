func throw(): Never ~ Error {
	throw Error.new()
}

func foobar(test, resolve: (): String) ~ Error {
	var value = if test() {
		set resolve()
	}
	else {
		throw()
	}

	echo(`\(value)`)
}
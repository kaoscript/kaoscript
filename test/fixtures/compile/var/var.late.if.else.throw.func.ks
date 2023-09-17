func foobar() ~ Error {
	var late x

	if x ?= quxbaz() {
	}
	else {
		error()
	}
}

func quxbaz(): String? {
	return null
}

func error(): Never ~ Error {
	throw Error.new()
}
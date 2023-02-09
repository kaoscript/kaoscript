extern class Error

func foobar(test, resolve) ~ Error {
	var value = if test() {
		throw new Error()
	}
	else {
		throw new Error()
	}
}
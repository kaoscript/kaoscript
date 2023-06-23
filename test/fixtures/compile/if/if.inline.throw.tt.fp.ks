extern class Error

func foobar(test, resolve) ~ Error {
	var value = if test() {
		throw Error.new()
	}
	else {
		set resolve()
	}
}
extern class Error

func foobar(test, resolve) ~ Error {
	var value = if test() {
		return 0
	}
	else {
		return 1
	}
}
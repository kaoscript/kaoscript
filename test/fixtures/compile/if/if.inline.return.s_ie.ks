extern class Error

func foobar(test, resolve): String ~ Error {
	var value = if test() {
		pick 0
	}
	else {
		return 1
	}
}
extern class Error
extern console

func foobar(test, resolve: (): String) ~ Error {
	var value = if test() {
		pick resolve()
	}
	else {
		throw Error.new()
	}

	console.log(`\(value)`)
}
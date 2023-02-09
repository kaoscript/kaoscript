extern class Error
extern console

func foobar(test, resolve: (): String) ~ Error {
	var value = if test() {
		pick resolve()
	}
	else {
		throw new Error()
	}

	console.log(`\(value)`)
}
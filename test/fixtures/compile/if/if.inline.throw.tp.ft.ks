extern class Error
extern console

func foobar(test, resolve: (): String) ~ Error {
	var value = if test() {
		set resolve()
	}
	else {
		throw Error.new()
	}

	console.log(`\(value)`)
}
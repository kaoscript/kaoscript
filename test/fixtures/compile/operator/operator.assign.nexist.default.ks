extern console: {
	log(...args)
}

extern class Error

func qux() ~ Error {
	var dyn foo = () => 'otto'

	if bar !?= foo() {
		throw new Error()
	}

	console.log(foo, bar)
}
extern console: {
	log(...args)
}

extern class Error

func qux() ~ Error {
	var dyn foo = () => 'otto'
	var dyn bar

	if bar !?= foo() {
		throw Error.new()
	}

	console.log(foo, bar)
}
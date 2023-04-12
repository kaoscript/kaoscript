extern console: {
	log(...args)
}

extern class Error

func foo() ~ Error {
	try {
		bar()
	}
	catch {
		console.log('catch')

		throw Error.new()
	}
	finally {
		console.log('finally')
	}
}

func bar() ~ Error {
	throw Error.new()
}
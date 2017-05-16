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
		
		throw new Error()
	}
	finally {
		console.log('finally')
	}
}

func bar() ~ Error {
	throw new Error()
}
extern console: {
	log(...args)
}

extern class Error

func qux() ~ Error {
	let foo = () => 'otto'

	if bar !?= foo() {
		throw new Error()
	}

	console.log(foo, bar)
}
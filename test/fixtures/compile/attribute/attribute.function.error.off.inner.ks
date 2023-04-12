func error() ~ Error {
	throw Error.new()
}


func foobar() {
	#![error(off)]

	error()
}
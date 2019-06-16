func error() ~ Error {
	throw new Error()
}


func foobar() {
	#![error(off)]

	error()
}
func error() ~ Error {
	throw Error.new()
}


#[error(off)]
func foobar() {
	error()
}
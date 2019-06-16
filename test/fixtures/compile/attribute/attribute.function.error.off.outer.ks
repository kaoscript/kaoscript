func error() ~ Error {
	throw new Error()
}


#[error(off)]
func foobar() {
	error()
}
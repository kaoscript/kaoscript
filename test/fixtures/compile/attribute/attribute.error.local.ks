extern sealed class Error

#[error(off)]
func foo() {
	throw Error.new()
}
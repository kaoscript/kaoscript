extern sealed class Error

#[error(off)]
func foo() {
	throw new Error()
}
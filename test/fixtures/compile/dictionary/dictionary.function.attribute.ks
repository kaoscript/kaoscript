extern sealed class SyntaxError

var foobar = {
	#[error(off)]
	corge() {
		throw new SyntaxError()
	}
}
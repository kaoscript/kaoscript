extern sealed class SyntaxError

const foobar = {
	#[error(off)]
	corge() {
		throw new SyntaxError()
	}
}
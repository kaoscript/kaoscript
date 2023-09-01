extern sealed class SyntaxError

var foobar = {
	#[error(off)]
	corge: func() {
		throw SyntaxError.new()
	}
}
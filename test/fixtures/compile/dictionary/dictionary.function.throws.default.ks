extern sealed class SyntaxError

const foobar = {
	corge() ~ SyntaxError {
		throw new SyntaxError()
	}
}
extern sealed class SyntaxError

var foobar = {
	corge() ~ SyntaxError {
		throw new SyntaxError()
	}
}
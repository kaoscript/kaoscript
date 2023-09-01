extern sealed class SyntaxError

var foobar = {
	corge: func() ~ SyntaxError {
		throw SyntaxError.new()
	}
}
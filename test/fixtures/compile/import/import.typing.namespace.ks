import 'npm:@kaoscript/runtime' {
	func createToken
	sealed class Lexer
	sealed class Parser
	sealed class Token
} => RT

class WHITESPACE extends RT.Token {
	static PATTERN	= /[^\r\n\S]+/
	static GROUP	= RT.Lexer.SKIPPED
}

var tokens = [WHITESPACE]

class MyParser extends RT.Parser {
	constructor() {
		super([], tokens)
	}
}
import '@kaoscript/runtime' as RT {
	func createToken
	sealed class Lexer
	sealed class Parser
	sealed class Token
}

class WHITESPACE extends RT.Token {
	static PATTERN	= /[^\r\n\S]+/
	static GROUP	= RT.Lexer.SKIPPED
}

const tokens = [WHITESPACE]

class MyParser extends RT.Parser {
	constructor() {
		super([], tokens)
	}
}
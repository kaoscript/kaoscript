import '@kaoscript/runtime' {
	func createToken
	sealed class Lexer
	sealed class Parser
	sealed class Token
}

class WHITESPACE extends Token {
	static PATTERN	= /[^\r\n\S]+/
	static GROUP	= Lexer.SKIPPED
}

var tokens = [WHITESPACE]

class MyParser extends Parser {
	constructor() {
		super([], tokens)
	}
}
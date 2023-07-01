import 'npm:@kaoscript/runtime' {
	func createToken
	sealed class Lexer
	sealed class Parser
	sealed class Token
} for {
	createToken => createChevrotainToken
	Lexer => ChevrotainLexer
	Parser => ChevrotainParser
	Token => ChevrotainToken
}

class WHITESPACE extends ChevrotainToken {
	static PATTERN	= /[^\r\n\S]+/
	static GROUP	= ChevrotainLexer.SKIPPED
}

var tokens = [WHITESPACE]

class MyParser extends ChevrotainParser {
	constructor() {
		super([], tokens)
	}
}
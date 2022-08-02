import '@kaoscript/runtime' {
	func createToken	=> createChevrotainToken
	sealed class Lexer	=> ChevrotainLexer
	sealed class Parser	=> ChevrotainParser
	sealed class Token	=> ChevrotainToken
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
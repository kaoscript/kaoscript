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

const tokens = [WHITESPACE]

class MyParser extends ChevrotainParser {
	constructor() {
		super([], tokens)
	}
}
module.exports = function() {
	var {createToken, Lexer, Parser, Token} = require("@kaoscript/runtime");
	class WHITESPACE extends Token {
		constructor() {
			super(...arguments);
			this.__ks_init();
		}
		__ks_init() {
		}
	}
	WHITESPACE.PATTERN = /[^\r\n\S]+/;
	WHITESPACE.GROUP = Lexer.SKIPPED;
	const tokens = [WHITESPACE];
	class MyParser extends Parser {
		constructor() {
			super([], tokens);
			this.__ks_init();
		}
		__ks_init() {
		}
	}
}
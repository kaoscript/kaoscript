module.exports = function() {
	var RT = require("@kaoscript/runtime");
	class WHITESPACE extends RT.Token {
		constructor() {
			super(...arguments);
			this.__ks_init();
		}
		__ks_init() {
		}
	}
	WHITESPACE.PATTERN = /[^\r\n\S]+/;
	WHITESPACE.GROUP = RT.Lexer.SKIPPED;
	const tokens = [WHITESPACE];
	class MyParser extends RT.Parser {
		constructor() {
			super([], tokens);
			this.__ks_init();
		}
		__ks_init() {
		}
	}
}
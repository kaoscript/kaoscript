module.exports = function() {
	var {createToken: createChevrotainToken, Lexer: ChevrotainLexer, Parser: ChevrotainParser, Token: ChevrotainToken} = require("@kaoscript/runtime");
	class WHITESPACE extends ChevrotainToken {
		constructor() {
			super(...arguments);
			this.constructor.prototype.__ks_init();
		}
		__ks_init() {
		}
	}
	WHITESPACE.PATTERN = /[^\r\n\S]+/;
	WHITESPACE.GROUP = ChevrotainLexer.SKIPPED;
	const tokens = [WHITESPACE];
	class MyParser extends ChevrotainParser {
		constructor() {
			super([], tokens);
			this.constructor.prototype.__ks_init();
		}
		__ks_init() {
		}
	}
};
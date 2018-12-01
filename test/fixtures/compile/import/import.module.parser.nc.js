require("kaoscript/register");
module.exports = function() {
	var __ks_SyntaxError = {};
	var parse = require("@kaoscript/parser")().parse;
	try {
		const ast = parse("const foo = 42");
	}
	catch(__ks_0) {
	}
};
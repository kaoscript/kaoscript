require("kaoscript/register");
module.exports = function() {
	var parse = require("@kaoscript/parser")().parse;
	try {
		const ast = parse("const foo = 42");
	}
	catch(error) {
		console.error(error);
	}
};
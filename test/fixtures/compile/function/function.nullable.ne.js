var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0) {
			x = null;
		}
		else if(x !== null && !Type.isNumber(x)) {
			throw new TypeError("'x' is not of type 'Number'");
		}
	}
	foo(42);
	foo(null);
};
var Operator = require("@kaoscript/runtime").Operator;
module.exports = function() {
	function foobar(x, y, z) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		if(z === void 0 || z === null) {
			throw new TypeError("'z' is not nullable");
		}
		x = Operator.modulo(x, y, z);
	}
};
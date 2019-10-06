var Operator = require("@kaoscript/runtime").Operator;
module.exports = function() {
	function foobar(a, b, c, d) {
		if(arguments.length < 4) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 4)");
		}
		if(a === void 0 || a === null) {
			throw new TypeError("'a' is not nullable");
		}
		if(b === void 0 || b === null) {
			throw new TypeError("'b' is not nullable");
		}
		if(c === void 0 || c === null) {
			throw new TypeError("'c' is not nullable");
		}
		if(d === void 0 || d === null) {
			throw new TypeError("'d' is not nullable");
		}
		if(Operator.lt(a, b) && Operator.lte(b, c) && Operator.lt(c, d)) {
		}
	}
};
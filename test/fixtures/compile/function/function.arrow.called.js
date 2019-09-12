var Operator = require("@kaoscript/runtime").Operator;
module.exports = function() {
	let four = (function(a) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(a === void 0 || a === null) {
			throw new TypeError("'a' is not nullable");
		}
		return Operator.division(a, 10);
	})(42);
};
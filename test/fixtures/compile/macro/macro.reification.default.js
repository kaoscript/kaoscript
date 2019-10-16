var Operator = require("@kaoscript/runtime").Operator;
module.exports = function() {
	function add3(x0, x1, x2) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(x0 === void 0 || x0 === null) {
			throw new TypeError("'x0' is not nullable");
		}
		if(x1 === void 0 || x1 === null) {
			throw new TypeError("'x1' is not nullable");
		}
		if(x2 === void 0 || x2 === null) {
			throw new TypeError("'x2' is not nullable");
		}
		return Operator.addOrConcat(x0, x1, x2);
	}
};
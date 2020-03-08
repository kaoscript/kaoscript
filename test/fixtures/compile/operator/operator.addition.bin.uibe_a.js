var {Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isNumber(x) && !Type.isBoolean(x)) {
			throw new TypeError("'x' is not of type 'Number' or 'Boolean'");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		return Operator.addOrConcat(x, y);
	}
};
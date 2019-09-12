var {Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		else if(!Type.isBoolean(y)) {
			throw new TypeError("'y' is not of type 'Boolean'");
		}
		x = Operator.addOrConcat(x, y);
	}
};
var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isString(x) && !Type.isBoolean(x)) {
			throw new TypeError("'x' is not of type 'String' or 'Boolean'");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		return Helper.concatString(x, y);
	}
};
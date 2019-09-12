var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isString(x)) {
			throw new TypeError("'x' is not of type 'String'");
		}
		if(y === void 0) {
			y = null;
		}
		else if(y !== null && !Type.isString(y)) {
			throw new TypeError("'y' is not of type 'String?'");
		}
		return Helper.concatString(x, y);
	}
};
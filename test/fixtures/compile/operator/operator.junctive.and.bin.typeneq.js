var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(!Type.isNumber(x) && !Type.isString(x)) {
		}
		if(!Type.isNumber(x) && !Type.isString(x)) {
		}
	}
};
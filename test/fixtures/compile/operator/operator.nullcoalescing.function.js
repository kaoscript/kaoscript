var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
	}
	function quxbaz(x, y, z) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(x === void 0) {
			x = null;
		}
		if(y === void 0) {
			y = null;
		}
		if(z === void 0 || z === null) {
			throw new TypeError("'z' is not nullable");
		}
		return foobar(Type.isValue(x) ? x : Type.isValue(y) ? y : z);
	}
};
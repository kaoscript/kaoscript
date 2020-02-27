var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(x, y, z = null) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		if(Type.isValue(z) || (x === true)) {
			if(Type.isValue(z)) {
			}
		}
	}
};
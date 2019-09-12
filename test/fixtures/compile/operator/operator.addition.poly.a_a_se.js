var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(x, y, z) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		if(z === void 0 || z === null) {
			throw new TypeError("'z' is not nullable");
		}
		else if(!Type.isString(z)) {
			throw new TypeError("'z' is not of type 'String'");
		}
		return x + y + z;
	}
};
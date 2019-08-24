var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(x, y, z, d) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		if(z === void 0) {
			z = null;
		}
		else if(z !== null && !Type.isString(z)) {
			throw new TypeError("'z' is not of type 'String?'");
		}
		if(d === void 0 || d === null) {
			d = 42;
		}
	}
	foobar(42, 24, null);
};
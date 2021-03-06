var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isBoolean(x)) {
			throw new TypeError("'x' is not of type 'Boolean'");
		}
		if(y === void 0) {
			y = null;
		}
		else if(y !== null && !Type.isBoolean(y)) {
			throw new TypeError("'y' is not of type 'Boolean?'");
		}
		return x && (y === true);
	}
};
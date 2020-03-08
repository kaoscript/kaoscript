var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(f) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(f === void 0 || f === null) {
			throw new TypeError("'f' is not nullable");
		}
		else if(!Type.isDictionary(f) || !Type.isNumber(f.x) || !Type.isNumber(f.y) || !Type.isFunction(f.foo)) {
			throw new TypeError("'f' is not of type 'Foobar'");
		}
		return f.foo();
	}
};
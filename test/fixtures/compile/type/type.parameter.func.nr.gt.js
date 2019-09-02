var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(fn) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(fn === void 0 || fn === null) {
			throw new TypeError("'fn' is not nullable");
		}
		else if(!Type.isFunction(fn)) {
			throw new TypeError("'fn' is not of type '(x: String)'");
		}
		fn("foobar");
	}
};
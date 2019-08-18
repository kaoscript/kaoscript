var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(foobar) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(foobar === void 0) {
			foobar = null;
		}
		else if(foobar !== null && !Type.isString(foobar)) {
			throw new TypeError("'foobar' is not of type 'String?'");
		}
		if(Type.isValue(foobar)) {
			return foobar;
		}
		else {
			return "foobar";
		}
	}
};
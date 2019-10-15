var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(a, b) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(a === void 0) {
			a = null;
		}
		if(b === void 0) {
			b = null;
		}
		if(!Type.isString(a) || !Type.isString(b)) {
			return false;
		}
		else {
			return a.toLowerCase() === b.toLowerCase();
		}
	}
};
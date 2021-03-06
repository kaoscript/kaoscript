var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(bar) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(bar === void 0 || bar === null) {
			throw new TypeError("'bar' is not nullable");
		}
		else if(!Type.isArray(bar)) {
			throw new TypeError("'bar' is not of type 'Array<String>'");
		}
	}
};
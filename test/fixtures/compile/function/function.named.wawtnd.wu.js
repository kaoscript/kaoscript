var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(bar, qux) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(bar === void 0 || bar === null) {
			throw new TypeError("'bar' is not nullable");
		}
		else if(!Type.isString(bar) && !Type.isNumber(bar)) {
			throw new TypeError("'bar' is not of type 'String' or 'Number'");
		}
		if(qux === void 0 || qux === null) {
			throw new TypeError("'qux' is not nullable");
		}
		else if(!Type.isNumber(qux)) {
			throw new TypeError("'qux' is not of type 'Number'");
		}
	}
};
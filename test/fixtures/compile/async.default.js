var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(bar, qux, __ks_cb) {
		if(arguments.length < 3) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(bar === void 0 || bar === null) {
			throw new TypeError("'bar' is not nullable");
		}
		else if(!Type.isString(bar)) {
			throw new TypeError("'bar' is not of type 'String'");
		}
		if(qux === void 0 || qux === null) {
			throw new TypeError("'qux' is not nullable");
		}
		else if(!Type.isNumber(qux)) {
			throw new TypeError("'qux' is not of type 'Number'");
		}
		if(!Type.isFunction(__ks_cb)) {
			throw new TypeError("'callback' must be a function");
		}
	}
}
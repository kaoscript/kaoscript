var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(bar, qux, __ks_cb) {
		if(arguments.length < 3) {
			let __ks_error = new SyntaxError("wrong number of arguments (" + arguments.length + " for 2 + 1)");
			if(arguments.length > 0 && Type.isFunction((__ks_cb = arguments[arguments.length - 1]))) {
				return __ks_cb(__ks_error);
			}
			else {
				throw __ks_error;
			}
		}
		else if(!Type.isFunction(__ks_cb)) {
			throw new TypeError("'callback' must be a function");
		}
		if(bar === void 0 || bar === null) {
			return __ks_cb(new TypeError("'bar' is not nullable"));
		}
		else if(!Type.isString(bar)) {
			return __ks_cb(new TypeError("'bar' is not of type 'String'"));
		}
		if(qux === void 0 || qux === null) {
			return __ks_cb(new TypeError("'qux' is not nullable"));
		}
		else if(!Type.isNumber(qux)) {
			return __ks_cb(new TypeError("'qux' is not of type 'Number'"));
		}
		__ks_cb();
	}
}
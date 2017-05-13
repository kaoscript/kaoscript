var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(x, __ks_cb) {
		if(arguments.length < 2) {
			let __ks_error = new SyntaxError("wrong number of arguments (" + arguments.length + " for 1 + 1)");
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
		if(x === void 0 || x === null) {
			return __ks_cb(new TypeError("'x' is not nullable"));
		}
		else if(!Type.isNumber(x)) {
			return __ks_cb(new TypeError("'x' is not of type 'Number'"));
		}
		return __ks_cb(null, "" + (x * 3));
	}
	return {
		foo: foo
	};
}
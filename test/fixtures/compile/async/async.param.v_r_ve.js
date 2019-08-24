var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(x) {
		let __ks_cb = arguments.length > 0 ? arguments[arguments.length - 1] : null;
		if(arguments.length < 3) {
			let __ks_error = new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2 + 1)");
			if(Type.isFunction(__ks_cb)) {
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
		let __ks_i = 0;
		let items = arguments.length > ++__ks_i + 2 ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length - 2) : [];
		let y = arguments[__ks_i];
		if(y === void 0 || y === null) {
			return __ks_cb(new TypeError("'y' is not nullable"));
		}
		__ks_cb();
	}
};
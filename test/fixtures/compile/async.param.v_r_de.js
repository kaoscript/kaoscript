var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(x) {
		let __ks_cb = arguments.length > 0 ? arguments[arguments.length - 1] : null;
		if(arguments.length < 2) {
			let __ks_error = new SyntaxError("wrong number of arguments (" + arguments.length + " for 1 + 1)");
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
		let __ks_i;
		let items = arguments.length > 2 ? Array.prototype.slice.call(arguments, 1, __ks_i = arguments.length - 1) : (__ks_i = 1, []);
		let y = 42;
		__ks_cb();
	}
};
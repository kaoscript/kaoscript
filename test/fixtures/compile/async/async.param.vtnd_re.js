var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo() {
		let __ks_cb = arguments.length > 0 ? arguments[arguments.length - 1] : null;
		if(arguments.length < 1) {
			let __ks_error = new SyntaxError("Wrong number of arguments (" + arguments.length + " for 0 + 1)");
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
		let __ks_i = -1;
		let x;
		if(arguments.length > ++__ks_i && (x = arguments[__ks_i]) !== void 0) {
			if(x !== null && !Type.isNumber(x)) {
				x = null;
				--__ks_i;
			}
		}
		else {
			x = null;
		}
		let items = arguments.length > ++__ks_i + 1 ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length - 1) : [];
		__ks_cb();
	}
};
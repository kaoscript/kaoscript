var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		var __ks_cb = arguments[arguments.length - 1];
		if(!Type.isFunction(__ks_cb)) {
			throw new SyntaxError("Callback can't be found");
		}
		var __ks_arguments = Array.prototype.slice.call(arguments, 0, arguments.length - 1);
		if(__ks_arguments.length === 0) {
			__ks_cb();
		}
		else if(__ks_arguments.length === 1) {
			let __ks_i = -1;
			let a = __ks_arguments[++__ks_i];
			if(a === void 0 || a === null) {
				return __ks_cb(new TypeError("'a' is not nullable"));
			}
			else if(!Type.isString(a)) {
				return __ks_cb(new TypeError("'a' is not of type 'String'"));
			}
			__ks_cb();
		}
		else {
			return __ks_cb(new SyntaxError("Wrong number of arguments"));
		}
	};
};
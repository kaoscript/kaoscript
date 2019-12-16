var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_foobar_0(__ks_cb) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 0 + 1)");
			}
			else if(!Type.isFunction(__ks_cb)) {
				throw new TypeError("'callback' must be a function");
			}
			__ks_cb();
		}
		__ks_func_foobar_1(a, __ks_cb) {
			if(arguments.length < 2) {
				let __ks_error = new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1 + 1)");
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
			if(a === void 0 || a === null) {
				return __ks_cb(new TypeError("'a' is not nullable"));
			}
			else if(!Type.isString(a)) {
				return __ks_cb(new TypeError("'a' is not of type 'String'"));
			}
			__ks_cb();
		}
		foobar() {
			if(arguments.length === 1) {
				return Foobar.prototype.__ks_func_foobar_0.apply(this, arguments);
			}
			else if(arguments.length === 2) {
				return Foobar.prototype.__ks_func_foobar_1.apply(this, arguments);
			}
			else {
				let __ks_cb, __ks_error = new SyntaxError("Wrong number of arguments");
				if(arguments.length > 0 && Type.isFunction((__ks_cb = arguments[arguments.length - 1]))) {
					return __ks_cb(__ks_error);
				}
				else {
					throw __ks_error;
				}
			}
		}
	}
};
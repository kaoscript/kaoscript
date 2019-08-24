var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Foo {
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
		__ks_func_foo_0(__ks_cb) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 0 + 1)");
			}
			else if(!Type.isFunction(__ks_cb)) {
				throw new TypeError("'callback' must be a function");
			}
			return __ks_cb(null, 42);
		}
		foo() {
			if(arguments.length === 1) {
				return Foo.prototype.__ks_func_foo_0.apply(this, arguments);
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
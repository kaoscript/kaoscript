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
				throw new SyntaxError("wrong number of arguments");
			}
		}
		__ks_func_foo_0(__ks_cb) {
			if(arguments.length < 1) {
				let __ks_error = new SyntaxError("wrong number of arguments (" + arguments.length + " for 0 + 1)");
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
			return __ks_cb(null, 42);
		}
		__ks_func_foo_1(x, __ks_cb) {
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
			return __ks_cb(null, x + 42);
		}
		foo() {
			if(arguments.length === 1) {
				return Foo.prototype.__ks_func_foo_0.apply(this, arguments);
			}
			else if(arguments.length === 2) {
				return Foo.prototype.__ks_func_foo_1.apply(this, arguments);
			}
			else {
				let __ks_cb, __ks_error = new SyntaxError("wrong number of arguments");
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
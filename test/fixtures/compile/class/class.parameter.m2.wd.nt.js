var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Foo {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0() {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			let __ks_i = -1;
			let __ks__;
			let foo = arguments.length > 1 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : "hello";
			let bar = arguments[++__ks_i];
			if(bar === void 0 || bar === null) {
				throw new TypeError("'bar' is not nullable");
			}
		}
		__ks_cons_1() {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			let __ks_i = -1;
			let __ks__;
			let foo = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : "hello";
			let bar = arguments[++__ks_i];
			if(bar === void 0 || bar === null) {
				throw new TypeError("'bar' is not nullable");
			}
			let qux = arguments[++__ks_i];
			if(qux === void 0 || qux === null) {
				throw new TypeError("'qux' is not nullable");
			}
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Foo.prototype.__ks_cons_0.apply(this, args);
			}
			else if(args.length === 2) {
				if(Type.isValue(args[0])) {
					Foo.prototype.__ks_cons_1.apply(this, args);
				}
				else {
					Foo.prototype.__ks_cons_0.apply(this, args);
				}
			}
			else if(args.length === 3) {
				Foo.prototype.__ks_cons_1.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
};
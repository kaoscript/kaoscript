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
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			let __ks_i = -1;
			let foo = arguments[++__ks_i];
			if(foo === void 0 || foo === null) {
				throw new TypeError("'foo' is not nullable");
			}
			let __ks__;
			let bar = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 ? __ks__ : null;
			let qux = arguments[++__ks_i];
			if(qux === void 0 || qux === null) {
				throw new TypeError("'qux' is not nullable");
			}
		}
		__ks_cons_1() {
			if(arguments.length < 3) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 3)");
			}
			let __ks_i = -1;
			let foo = arguments[++__ks_i];
			if(foo === void 0 || foo === null) {
				throw new TypeError("'foo' is not nullable");
			}
			let __ks__;
			let bar = arguments.length > 3 && (__ks__ = arguments[++__ks_i]) !== void 0 ? __ks__ : null;
			let qux = arguments[++__ks_i];
			if(qux === void 0 || qux === null) {
				throw new TypeError("'qux' is not nullable");
			}
			else if(!Type.isString(qux)) {
				throw new TypeError("'qux' is not of type 'String'");
			}
			let corge = arguments[++__ks_i];
			if(corge === void 0 || corge === null) {
				throw new TypeError("'corge' is not nullable");
			}
		}
		__ks_cons(args) {
			if(args.length === 2) {
				Foo.prototype.__ks_cons_0.apply(this, args);
			}
			else if(args.length === 3) {
				if(Type.isString(args[1])) {
					Foo.prototype.__ks_cons_1.apply(this, args);
				}
				else {
					Foo.prototype.__ks_cons_0.apply(this, args);
				}
			}
			else if(args.length === 4) {
				Foo.prototype.__ks_cons_1.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
};
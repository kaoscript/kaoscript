module.exports = function() {
	class Foo {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(foo, bar, qux) {
			if(arguments.length < 3) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 3)");
			}
			if(foo === void 0 || foo === null) {
				throw new TypeError("'foo' is not nullable");
			}
			if(bar === void 0) {
				bar = null;
			}
			if(qux === void 0 || qux === null) {
				throw new TypeError("'qux' is not nullable");
			}
		}
		__ks_cons_1(foo, qux) {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(foo === void 0 || foo === null) {
				throw new TypeError("'foo' is not nullable");
			}
			if(qux === void 0 || qux === null) {
				throw new TypeError("'qux' is not nullable");
			}
		}
		__ks_cons(args) {
			if(args.length === 2) {
				Foo.prototype.__ks_cons_1.apply(this, args);
			}
			else if(args.length === 3) {
				Foo.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
};
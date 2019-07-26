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
		__ks_func_toString_0() {
			return "foo";
		}
		toString() {
			if(arguments.length === 0) {
				return Foo.prototype.__ks_func_toString_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	class Bar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(foo) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(foo === void 0) {
				foo = null;
			}
			else if(foo !== null && !Type.is(foo, Foo)) {
				throw new TypeError("'foo' is not of type 'Foo'");
			}
			this._foo = foo;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Bar.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_foo_0() {
			return this._foo;
		}
		foo() {
			if(arguments.length === 0) {
				return Bar.prototype.__ks_func_foo_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	class Qux extends Bar {
		__ks_init() {
			Bar.prototype.__ks_init.call(this);
		}
		__ks_cons_0() {
			Bar.prototype.__ks_cons.call(this, [new Foo()]);
		}
		__ks_cons(args) {
			if(args.length === 0) {
				Qux.prototype.__ks_cons_0.apply(this);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	return {
		Qux: Qux
	};
};
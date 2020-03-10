var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_0() {
			this._foo = 42;
			this.bar = "foobar";
		}
		__ks_init() {
			Foobar.prototype.__ks_init_0.call(this);
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_foo_0() {
			return this._foo;
		}
		__ks_func_foo_1(foo) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(foo === void 0 || foo === null) {
				throw new TypeError("'foo' is not nullable");
			}
			else if(!Type.isNumber(foo)) {
				throw new TypeError("'foo' is not of type 'Number'");
			}
			this._foo = foo;
			return this;
		}
		foo() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_foo_0.apply(this);
			}
			else if(arguments.length === 1) {
				return Foobar.prototype.__ks_func_foo_1.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};
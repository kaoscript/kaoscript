var Helper = require("@kaoscript/runtime").Helper;
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
	}
	class Bar extends Foo {
		__ks_init() {
			Foo.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			Foo.prototype.__ks_cons.call(this, args);
		}
		__ks_func_greet_0(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			return Helper.concatString("Hello ", name, "!");
		}
		greet() {
			if(arguments.length === 1) {
				return Bar.prototype.__ks_func_greet_0.apply(this, arguments);
			}
			else if(Foo.prototype.greet) {
				return Foo.prototype.greet.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	class Qux extends Bar {
		__ks_init() {
			Bar.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			Bar.prototype.__ks_cons.call(this, args);
		}
	}
};
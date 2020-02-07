var Helper = require("@kaoscript/runtime").Helper;
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
		__ks_func_foo_0(x) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			let __ks_i = 0;
			let items = Array.prototype.slice.call(arguments, ++__ks_i, __ks_i = arguments.length - 1);
			let y = arguments[__ks_i];
			if(y === void 0 || y === null) {
				throw new TypeError("'y' is not nullable");
			}
			return Helper.concatString("[", x, ", ", items, ", ", y, "]");
		}
		foo() {
			return Foobar.prototype.__ks_func_foo_0.apply(this, arguments);
		}
	}
	const x = new Foobar();
	console.log(Helper.toString(x.foo()));
	console.log(Helper.toString(x.foo(1)));
	console.log(x.foo(1, 2));
	console.log(x.foo(1, 2, 3));
	console.log(x.foo(1, 2, 3, 4));
};
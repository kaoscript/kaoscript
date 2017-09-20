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
				throw new SyntaxError("wrong number of arguments");
			}
		}
		__ks_func_foo_0(x) {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			let __ks_i;
			let items = arguments.length > 2 ? Array.prototype.slice.call(arguments, 1, __ks_i = arguments.length - 1) : (__ks_i = 1, []);
			let y = arguments[__ks_i];
			if(y === void 0 || y === null) {
				throw new TypeError("'y' is not nullable");
			}
			return "[" + x + ", " + items + ", " + y + "]";
		}
		foo() {
			return Foobar.prototype.__ks_func_foo_0.apply(this, arguments);
		}
	}
	const x = new Foobar();
	console.log("" + x.foo());
	console.log("" + x.foo(1));
	console.log(x.foo(1, 2));
	console.log(x.foo(1, 2, 3));
	console.log(x.foo(1, 2, 3, 4));
};
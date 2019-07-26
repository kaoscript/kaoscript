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
		__ks_func_foo_0(x, ...items) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			let y = 42;
			return "[" + x + ", " + items + ", " + y + "]";
		}
		foo() {
			return Foobar.prototype.__ks_func_foo_0.apply(this, arguments);
		}
	}
	const x = new Foobar();
	console.log("" + x.foo());
	console.log(x.foo(1));
	console.log(x.foo(1, 2));
	console.log(x.foo(1, 2, 3, 4));
};
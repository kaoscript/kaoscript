var Type = require("@kaoscript/runtime").Type;
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
		__ks_func_foo_0() {
			let __ks_i = -1;
			let x;
			if(arguments.length > 0 && (x = arguments[++__ks_i]) !== void 0) {
				if(x !== null && !Type.isNumber(x)) {
					throw new TypeError("'x' is not of type 'Number?'");
				}
			}
			else {
				x = null;
			}
			let items = Array.prototype.slice.call(arguments, ++__ks_i, arguments.length);
			return "[" + x + ", " + items + "]";
		}
		foo() {
			return Foobar.prototype.__ks_func_foo_0.apply(this, arguments);
		}
	}
	const x = new Foobar();
	console.log(x.foo());
	console.log(x.foo(1));
	console.log(x.foo("foo"));
	console.log(x.foo(1, 2));
	console.log(x.foo("foo", 1));
};
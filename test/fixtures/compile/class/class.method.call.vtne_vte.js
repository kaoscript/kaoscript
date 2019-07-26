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
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			let __ks_i = -1;
			let x;
			if(arguments.length > 1 && (x = arguments[++__ks_i]) !== void 0) {
				if(x !== null && !Type.isNumber(x)) {
					throw new TypeError("'x' is not of type 'Number'");
				}
			}
			else {
				x = null;
			}
			let y = arguments[++__ks_i];
			if(y === void 0 || y === null) {
				throw new TypeError("'y' is not nullable");
			}
			else if(!Type.isString(y)) {
				throw new TypeError("'y' is not of type 'String'");
			}
			return "[" + x + ", " + y + "]";
		}
		foo() {
			if(arguments.length >= 1 && arguments.length <= 2) {
				return Foobar.prototype.__ks_func_foo_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	const x = new Foobar();
	console.log("" + x.foo());
	console.log("" + x.foo(1));
	console.log(x.foo("foo"));
	console.log(x.foo(1, "foo"));
	console.log("" + x.foo("foo", "bar"));
};
var {Helper, Type} = require("@kaoscript/runtime");
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
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isString(x)) {
				throw new TypeError("'x' is not of type 'String'");
			}
			let __ks_i = 0;
			let y;
			if(arguments.length > ++__ks_i && (y = arguments[__ks_i]) !== void 0) {
				if(y !== null && !Type.isString(y)) {
					if(arguments.length - __ks_i < 2) {
						y = null;
						--__ks_i;
					}
					else {
						throw new TypeError("'y' is not of type 'String?'");
					}
				}
			}
			else {
				y = null;
			}
			let z;
			if(arguments.length > ++__ks_i && (z = arguments[__ks_i]) !== void 0 && z !== null) {
				if(!Type.isBoolean(z)) {
					throw new TypeError("'z' is not of type 'Boolean'");
				}
			}
			else {
				z = false;
			}
			return Helper.concatString("[", x, ", ", y, ", ", z, "]");
		}
		foo() {
			if(arguments.length >= 1 && arguments.length <= 3) {
				return Foobar.prototype.__ks_func_foo_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	const x = new Foobar();
	console.log(x.foo("foo"));
	console.log(x.foo("foo", "bar"));
	console.log(x.foo("foo", true));
	console.log(x.foo("foo", "bar", true));
};
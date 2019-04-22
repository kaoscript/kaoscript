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
				throw new SyntaxError("wrong number of arguments");
			}
		}
		__ks_func_foo_0(x) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isString(x)) {
				throw new TypeError("'x' is not of type 'String'");
			}
		}
		foo() {
			if(arguments.length === 1) {
				return Foobar.prototype.__ks_func_foo_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_qux_0(x) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.is(x, Qux)) {
				throw new TypeError("'x' is not of type 'Qux'");
			}
		}
		qux() {
			if(arguments.length === 1) {
				return Foobar.prototype.__ks_func_qux_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
	class Qux {
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
	}
	return {
		Foobar: Foobar
	};
};
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
		__ks_func_foobar_0(...args) {
			return 0;
		}
		foobar() {
			return Foobar.prototype.__ks_func_foobar_0.apply(this, arguments);
		}
	}
	class Quxbaz extends Foobar {
		__ks_init() {
			Foobar.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			Foobar.prototype.__ks_cons.call(this, args);
		}
		__ks_func_foobar_0(a) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(a === void 0 || a === null) {
				throw new TypeError("'a' is not nullable");
			}
			else if(!Type.isNumber(a)) {
				throw new TypeError("'a' is not of type 'Number'");
			}
			return 1;
		}
		__ks_func_foobar_1(a, b) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(a === void 0 || a === null) {
				throw new TypeError("'a' is not nullable");
			}
			else if(!Type.isNumber(a)) {
				throw new TypeError("'a' is not of type 'Number'");
			}
			if(b === void 0 || b === null) {
				throw new TypeError("'b' is not nullable");
			}
			else if(!Type.isNumber(b)) {
				throw new TypeError("'b' is not of type 'Number'");
			}
			return 2;
		}
		foobar() {
			if(arguments.length === 1) {
				if(Type.isNumber(arguments[0])) {
					return Quxbaz.prototype.__ks_func_foobar_0.apply(this, arguments);
				}
			}
			else if(arguments.length === 2) {
				if(Type.isNumber(arguments[0]) && Type.isNumber(arguments[1])) {
					return Quxbaz.prototype.__ks_func_foobar_1.apply(this, arguments);
				}
			}
			return Foobar.prototype.foobar.apply(this, arguments);
		}
	}
};
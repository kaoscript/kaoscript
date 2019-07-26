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
		__ks_func_foobar_0(test) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(test === void 0 || test === null) {
				throw new TypeError("'test' is not nullable");
			}
			else if(!Type.isBoolean(test)) {
				throw new TypeError("'test' is not of type 'Boolean'");
			}
			if(test) {
				return new Quxbaz();
			}
			else {
				return new Foobar();
			}
		}
		foobar() {
			if(arguments.length === 1) {
				return Foobar.prototype.__ks_func_foobar_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	class Quxbaz extends Foobar {
		__ks_init() {
			Foobar.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			Foobar.prototype.__ks_cons.call(this, args);
		}
	}
};
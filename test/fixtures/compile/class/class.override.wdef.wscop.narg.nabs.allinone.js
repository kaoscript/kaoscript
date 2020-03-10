var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		return "";
	}
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
		__ks_func_foobar_0(x) {
			if(x === void 0 || x === null) {
				x = this.__ks_default_0_0();
			}
			else if(!Type.isString(x)) {
				throw new TypeError("'x' is not of type 'String'");
			}
			return x;
		}
		__ks_default_0_0() {
			return foobar();
		}
		foobar() {
			if(arguments.length >= 0 && arguments.length <= 1) {
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
		__ks_func_foobar_0(x) {
			if(x === void 0 || x === null) {
				x = this.__ks_default_0_0();
			}
			else if(!Type.isString(x)) {
				throw new TypeError("'x' is not of type 'String'");
			}
			return x;
		}
		foobar() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Quxbaz.prototype.__ks_func_foobar_0.apply(this, arguments);
			}
			return Foobar.prototype.foobar.apply(this, arguments);
		}
	}
	return {
		Foobar: Foobar,
		Quxbaz: Quxbaz
	};
};
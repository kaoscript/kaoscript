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
		__ks_func_isNamed_0() {
			return false;
		}
		isNamed() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_isNamed_0.apply(this);
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
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isInstance(x, Foobar)) {
				throw new TypeError("'x' is not of type 'Foobar'");
			}
			if(!Type.isInstance(x, Quxbaz) || !(x.isNamed() === true)) {
				return false;
			}
			const name = x.name();
		}
		foobar() {
			if(arguments.length === 1) {
				return Quxbaz.prototype.__ks_func_foobar_0.apply(this, arguments);
			}
			else if(Foobar.prototype.foobar) {
				return Foobar.prototype.foobar.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_isNamed_0() {
			return true;
		}
		isNamed() {
			if(arguments.length === 0) {
				return Quxbaz.prototype.__ks_func_isNamed_0.apply(this);
			}
			return Foobar.prototype.isNamed.apply(this, arguments);
		}
		__ks_func_name_0() {
			return "quxbaz";
		}
		name() {
			if(arguments.length === 0) {
				return Quxbaz.prototype.__ks_func_name_0.apply(this);
			}
			else if(Foobar.prototype.name) {
				return Foobar.prototype.name.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};
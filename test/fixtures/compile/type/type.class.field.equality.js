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
	}
	class Quxbaz extends Foobar {
		__ks_init() {
			Foobar.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			Foobar.prototype.__ks_cons.call(this, args);
		}
		__ks_func_quxbaz_0() {
		}
		quxbaz() {
			if(arguments.length === 0) {
				return Quxbaz.prototype.__ks_func_quxbaz_0.apply(this);
			}
			else if(Foobar.prototype.quxbaz) {
				return Foobar.prototype.quxbaz.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	class Corge {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._foo = new Foobar();
		}
		__ks_init() {
			Corge.prototype.__ks_init_1.call(this);
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_qux_0() {
			if(Type.isClassInstance(this._foo, Quxbaz)) {
				this._foo.quxbaz();
			}
		}
		qux() {
			if(arguments.length === 0) {
				return Corge.prototype.__ks_func_qux_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};
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
		__ks_func_foobar_0() {
			return this;
		}
		foobar() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_foobar_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_quxbaz_0() {
			return true;
		}
		quxbaz() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_quxbaz_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		static __ks_sttc_create_0() {
			return new Foobar();
		}
		static create() {
			if(arguments.length === 0) {
				return Foobar.__ks_sttc_create_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	let x, __ks_0;
	if((Type.isValue(__ks_0 = Foobar.create().foobar()) ? (x = __ks_0, true) : false) && x.quxbaz()) {
	}
};
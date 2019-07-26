var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Quxbaz {
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
		static __ks_sttc_get_0() {
			return new Quxbaz();
		}
		static get() {
			if(arguments.length === 0) {
				return Quxbaz.__ks_sttc_get_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	class Foobar extends Quxbaz {
		__ks_init() {
			Quxbaz.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			Quxbaz.prototype.__ks_cons.call(this, args);
		}
		static __ks_sttc_get_0() {
			return new Foobar();
		}
		static get() {
			if(arguments.length === 0) {
				return Foobar.__ks_sttc_get_0.apply(this);
			}
			return Quxbaz.get.apply(null, arguments);
		}
	}
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.is(x, Foobar)) {
			throw new TypeError("'x' is not of type 'Foobar'");
		}
	}
	const x = Foobar.get();
	foobar(x);
	return {
		Foobar: Foobar,
		Quxbaz: Quxbaz
	};
};
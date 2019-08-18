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
		static __ks_sttc_get_0(x) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isString(x)) {
				throw new TypeError("'x' is not of type 'String'");
			}
			return new Foobar();
		}
		static get() {
			if(arguments.length === 1) {
				return Foobar.__ks_sttc_get_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	function foobar(x = null) {
		if(x !== null && !(Type.is(x, Foobar) || Type.isString(x))) {
			throw new TypeError("'x' is not of type 'FS?'");
		}
		if(!Type.isValue(x)) {
			x = Foobar.get("foobar");
		}
		if(Type.isString(x)) {
			x = Foobar.get(x);
		}
		quxbaz(x);
	}
	function quxbaz(x) {
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
};
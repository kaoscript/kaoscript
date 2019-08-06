var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		let __ks_i = -1;
		let f = arguments[++__ks_i];
		if(f === void 0 || f === null) {
			throw new TypeError("'f' is not nullable");
		}
		else if(!Type.is(f, Foobar)) {
			throw new TypeError("'f' is not of type 'Foobar'");
		}
		let __ks__;
		let x = arguments.length > 1 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : f.foobar();
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
		__ks_func_foobar_0() {
			return 42;
		}
		foobar() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_foobar_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};
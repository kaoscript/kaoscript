var {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_0() {
			this._values = new Dictionary();
		}
		__ks_init() {
			Foobar.prototype.__ks_init_0.call(this);
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_foobar_0() {
			const values = Helper.concatDictionary(this._values);
		}
		foobar() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_foobar_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};
var Dictionary = require("@kaoscript/runtime").Dictionary;
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
	class Quxbaz {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_0() {
			this._options = (() => {
				const d = new Dictionary();
				d.class = Foobar;
				return d;
			})();
		}
		__ks_init() {
			Quxbaz.prototype.__ks_init_0.call(this);
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_new_0() {
			const foo = new this._options.class();
		}
		new() {
			if(arguments.length === 0) {
				return Quxbaz.prototype.__ks_func_new_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};
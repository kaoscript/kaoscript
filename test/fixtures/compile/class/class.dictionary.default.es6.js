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
		__ks_func_data_0() {
			this._z = 1;
			return (() => {
				const d = new Dictionary();
				x: this._x;
				y: this._y;
				d.power = (() => {
					const d = new Dictionary();
					z: this._z;
					return d;
				})();
				return d;
			})();
		}
		data() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_data_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};
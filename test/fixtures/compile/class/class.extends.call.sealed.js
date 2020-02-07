var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	var __ks_Dictionary = {};
	__ks_Dictionary.__ks_sttc_merge_0 = function(...args) {
		return new Dictionary();
	};
	__ks_Dictionary._cm_merge = function() {
		var args = Array.prototype.slice.call(arguments);
		return __ks_Dictionary.__ks_sttc_merge_0.apply(null, args);
	};
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(options) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(options === void 0 || options === null) {
				throw new TypeError("'options' is not nullable");
			}
			this._x = options.x;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Foobar.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	class Quxbaz extends Foobar {
		__ks_init() {
			Foobar.prototype.__ks_init.call(this);
		}
		__ks_cons_0(options = null) {
			Foobar.prototype.__ks_cons.call(this, [__ks_Dictionary._cm_merge((() => {
				const d = new Dictionary();
				d.x = 0;
				d.y = 0;
				return d;
			})(), options)]);
		}
		__ks_cons(args) {
			if(args.length >= 0 && args.length <= 1) {
				Quxbaz.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
};
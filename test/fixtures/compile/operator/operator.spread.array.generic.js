const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
		static __ks_new_0() {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
			this._values = [];
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		clone() {
			return this.__ks_func_clone_rt.call(null, this, this, arguments);
		}
		__ks_func_clone_0() {
			const clone = Foobar.__ks_new_0();
			clone._values = [...this._values];
			return clone;
		}
		__ks_func_clone_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_clone_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
};
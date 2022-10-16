const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
		static __ks_new_0() {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			o.__ks_cons_0();
			return o;
		}
		static __ks_new_1(...args) {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			o.__ks_cons_1(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0() {
			Foobar.prototype.__ks_cons_1.call(this, 0);
		}
		__ks_cons_1(x) {
			this._x = x;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isValue;
			if(args.length === 0) {
				return Foobar.prototype.__ks_cons_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return Foobar.prototype.__ks_cons_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};
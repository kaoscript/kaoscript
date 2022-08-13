const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
		static __ks_new_0(...args) {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(x) {
			this.__ks_func_x_0(x);
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isNumber;
			if(args.length === 1) {
				if(t0(args[0])) {
					return Foobar.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		x() {
			return this.__ks_func_x_rt.call(null, this, this, arguments);
		}
		__ks_func_x_0(x) {
			this._x = x;
			const y = this._x / 2;
		}
		__ks_func_x_rt(that, proto, args) {
			const t0 = Type.isNumber;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_x_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	return {
		Foobar
	};
};
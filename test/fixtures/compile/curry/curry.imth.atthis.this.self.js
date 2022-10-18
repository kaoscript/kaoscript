const {Helper, Type} = require("@kaoscript/runtime");
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
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0(x, y, z) {
			return 1;
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 3) {
				if(t0(args[0]) && t0(args[1]) && t0(args[2])) {
					return proto.__ks_func_foobar_0.call(that, args[0], args[1], args[2]);
				}
			}
			throw Helper.badArgs();
		}
		quxbaz() {
			return this.__ks_func_quxbaz_rt.call(null, this, this, arguments);
		}
		__ks_func_quxbaz_0() {
			const fn = Helper.vcurry(this.foobar, this, 0, 1);
			fn(2);
		}
		__ks_func_quxbaz_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_quxbaz_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
};
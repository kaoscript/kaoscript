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
		__ks_func_foobar_0(value) {
			if(value === void 0) {
				value = null;
			}
			return Type.isValue(value) ? this.__ks_func_quxbaz_0(quxbaz(value)) : null;
		}
		__ks_func_foobar_rt(that, proto, args) {
			if(args.length === 1) {
				return proto.__ks_func_foobar_0.call(that, args[0]);
			}
			throw Helper.badArgs();
		}
		quxbaz() {
			return this.__ks_func_quxbaz_rt.call(null, this, this, arguments);
		}
		__ks_func_quxbaz_0(value) {
			if(value === void 0) {
				value = null;
			}
		}
		__ks_func_quxbaz_rt(that, proto, args) {
			if(args.length === 1) {
				return proto.__ks_func_quxbaz_0.call(that, args[0]);
			}
			throw Helper.badArgs();
		}
	}
};
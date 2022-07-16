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
		static __ks_sttc_foobar_0(index, arr) {
			const data = Type.isNumber(index) ? arr[index] : index;
			return Quxbaz.__ks_sttc_foobar_1(index, data, arr);
		}
		static foobar() {
			const t0 = Type.isValue;
			const t1 = Type.isArray;
			if(arguments.length === 2) {
				if(t0(arguments[0]) && t1(arguments[1])) {
					return Foobar.__ks_sttc_foobar_0(arguments[0], arguments[1]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class Quxbaz extends Foobar {
		static __ks_new_0() {
			const o = Object.create(Quxbaz.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		static __ks_sttc_foobar_1(index, data, arr) {
		}
		static foobar() {
			const t0 = Type.isValue;
			const t1 = Type.isArray;
			if(arguments.length === 3) {
				if(t0(arguments[0]) && t0(arguments[1]) && t1(arguments[2])) {
					return Quxbaz.__ks_sttc_foobar_1(arguments[0], arguments[1], arguments[2]);
				}
			}
			if(Foobar.foobar) {
				return Foobar.foobar.apply(null, arguments);
			}
			throw Helper.badArgs();
		}
	}
};
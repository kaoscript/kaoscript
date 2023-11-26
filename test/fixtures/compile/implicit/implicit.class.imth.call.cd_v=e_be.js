const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const FontWeight = Helper.enum(Number, "Bold", 0, "Normal", 1);
	class Style {
		static __ks_new_0() {
			const o = Object.create(Style.prototype);
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
		__ks_func_foobar_0(bold) {
			this.__ks_func_quxbaz_0(bold ? FontWeight.Bold : null);
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = Type.isBoolean;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		quxbaz() {
			return this.__ks_func_quxbaz_rt.call(null, this, this, arguments);
		}
		__ks_func_quxbaz_0(weight) {
			if(weight === void 0) {
				weight = null;
			}
		}
		__ks_func_quxbaz_rt(that, proto, args) {
			const t0 = value => Type.isEnumInstance(value, FontWeight) || Type.isNull(value);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_quxbaz_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};
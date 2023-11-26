const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const FontWeight = Helper.enum(Number, 0, "Bold", 0, "Normal", 1);
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
		static __ks_sttc_foobar_0(weight) {
			if(weight === void 0 || weight === null) {
				weight = FontWeight.Normal;
			}
		}
		static foobar() {
			const t0 = value => Type.isEnumInstance(value, FontWeight) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(arguments, pts, idx);
			let pts;
			if(arguments.length <= 1) {
				if(Helper.isVarargs(arguments, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
					return Style.__ks_sttc_foobar_0(Helper.getVararg(arguments, 0, pts[1]));
				}
			}
			throw Helper.badArgs();
		}
	}
};
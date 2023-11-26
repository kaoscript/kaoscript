const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const FontWeight = Helper.enum(Number, 0, "Bold", 0, "Normal", 1);
	class Style {
		static __ks_new_0(...args) {
			const o = Object.create(Style.prototype);
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
		__ks_cons_0(weight) {
			if(weight === void 0 || weight === null) {
				weight = FontWeight.Normal;
			}
			this._weight = weight;
		}
		__ks_cons_rt(that, args) {
			const t0 = value => Type.isEnumInstance(value, FontWeight) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length <= 1) {
				if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
					return Style.prototype.__ks_cons_0.call(that, Helper.getVararg(args, 0, pts[1]));
				}
			}
			throw Helper.badArgs();
		}
	}
};
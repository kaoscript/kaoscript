const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const FontWeight = Helper.enum(Number, "Bold", 0, "Normal", 1);
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
		__ks_cons_0(fontWeight) {
			this._fontWeight = fontWeight;
		}
		__ks_cons_rt(that, args) {
			const t0 = value => Type.isEnumInstance(value, FontWeight);
			if(args.length === 1) {
				if(t0(args[0])) {
					return Style.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	const bold = Style.__ks_new_0(FontWeight.Bold);
};
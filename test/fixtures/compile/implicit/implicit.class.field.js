const {Helper} = require("@kaoscript/runtime");
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
			this._fontWeight = FontWeight.Bold;
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
	}
};
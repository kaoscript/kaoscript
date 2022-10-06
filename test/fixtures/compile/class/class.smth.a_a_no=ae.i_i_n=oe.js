const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
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
		static __ks_sttc_foobar_0(x, y, options) {
			return 1;
		}
		static foobar(kws, ...args) {
			const t0 = Type.isValue;
			if(t0(kws.options)) {
				if(args.length === 2) {
					if(t0(args[0]) && t0(args[1])) {
						return Foobar.__ks_sttc_foobar_0(args[0], args[1], kws.options);
					}
				}
			}
			throw Helper.badArgs();
		}
	}
	Foobar.__ks_sttc_foobar_0(0, 1, new Dictionary());
};
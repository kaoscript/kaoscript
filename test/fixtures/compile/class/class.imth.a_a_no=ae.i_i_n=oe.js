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
		foobar(kws, ...args) {
			return this.__ks_func_foobar_rt.call(null, this, this, kws, args);
		}
		__ks_func_foobar_0(x, y, options) {
			return 1;
		}
		__ks_func_foobar_rt(that, proto, kws, args) {
			const t0 = Type.isValue;
			if(t0(kws.options)) {
				if(args.length === 2) {
					if(t0(args[0]) && t0(args[1])) {
						return proto.__ks_func_foobar_0.call(that, args[0], args[1], kws.options);
					}
				}
			}
			throw Helper.badArgs();
		}
	}
	const f = Foobar.__ks_new_0();
	f.__ks_func_foobar_0(0, 1, new Dictionary());
};
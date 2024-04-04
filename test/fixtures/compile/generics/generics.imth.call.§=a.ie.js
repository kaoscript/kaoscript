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
		foobar(gens, ...args) {
			return this.__ks_func_foobar_rt.call(null, this, this, gens || {}, args);
		}
		__ks_func_foobar_0(x) {
			return x;
		}
		__ks_func_foobar_rt(that, proto, gens, args) {
			const t0 = gens.T || Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	const value = Foobar.__ks_new_0();
	console.log(Helper.toString(value.__ks_func_foobar_0(0)));
};
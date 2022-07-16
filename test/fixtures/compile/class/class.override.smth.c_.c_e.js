const {Helper} = require("@kaoscript/runtime");
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
		static __ks_sttc_foobar_0() {
			return 1;
		}
		static foobar() {
			if(arguments.length === 0) {
				return Foobar.__ks_sttc_foobar_0();
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
		static __ks_sttc_foobar_0() {
			return 2;
		}
		static foobar() {
			if(arguments.length === 0) {
				return Quxbaz.__ks_sttc_foobar_0();
			}
			if(Foobar.foobar) {
				return Foobar.foobar.apply(null, arguments);
			}
			throw Helper.badArgs();
		}
	}
};
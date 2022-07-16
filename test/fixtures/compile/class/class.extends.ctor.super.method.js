const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	class Master {
		static __ks_new_0() {
			const o = Object.create(Master.prototype);
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
		name() {
			return this.__ks_func_name_rt.call(null, this, this, arguments);
		}
		__ks_func_name_0() {
			return "Master";
		}
		__ks_func_name_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_name_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
	class Subby extends Master {
		static __ks_new_0() {
			const o = Object.create(Subby.prototype);
			o.__ks_init();
			o.__ks_cons_0();
			return o;
		}
		__ks_cons_0() {
			const name = super.__ks_func_name_0();
		}
		__ks_cons_rt(that, args) {
			if(args.length === 0) {
				return Subby.prototype.__ks_cons_0.call(that);
			}
			throw Helper.badArgs();
		}
		__ks_func_name_0() {
			return "Subby";
		}
	}
};
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Timezone {
		static __ks_new_0(...args) {
			const o = Object.create(Timezone.prototype);
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
		__ks_cons_0(name, rules) {
			for(let __ks_0 = 0, __ks_1 = rules.length, rule; __ks_0 < __ks_1; ++__ks_0) {
				rule = rules[__ks_0];
			}
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isValue;
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return Timezone.prototype.__ks_cons_0.call(that, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		}
		static __ks_sttc_add_0(zones, links, rules) {
			for(const name in zones) {
			}
		}
		static add() {
			const t0 = Type.isValue;
			if(arguments.length === 3) {
				if(t0(arguments[0]) && t0(arguments[1]) && t0(arguments[2])) {
					return Timezone.__ks_sttc_add_0(arguments[0], arguments[1], arguments[2]);
				}
			}
			throw Helper.badArgs();
		}
	}
	return {
		Timezone
	};
};
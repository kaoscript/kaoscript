module.exports = function() {
	class Timezone {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(name, rules) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			if(rules === void 0 || rules === null) {
				throw new TypeError("'rules' is not nullable");
			}
			for(let __ks_0 = 0, __ks_1 = rules.length, rule; __ks_0 < __ks_1; ++__ks_0) {
				rule = rules[__ks_0];
			}
		}
		__ks_cons(args) {
			if(args.length === 2) {
				Timezone.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		static __ks_sttc_add_0(zones, links, rules) {
			if(arguments.length < 3) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
			}
			if(zones === void 0 || zones === null) {
				throw new TypeError("'zones' is not nullable");
			}
			if(links === void 0 || links === null) {
				throw new TypeError("'links' is not nullable");
			}
			if(rules === void 0 || rules === null) {
				throw new TypeError("'rules' is not nullable");
			}
			for(const name in zones) {
			}
		}
		static add() {
			if(arguments.length === 3) {
				return Timezone.__ks_sttc_add_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	return {
		Timezone: Timezone
	};
};
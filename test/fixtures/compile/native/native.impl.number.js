const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Number = {};
	__ks_Number.__ks_func_mod_0 = function(max) {
		if(isNaN(this) === true) {
			return 0;
		}
		else {
			let n = this % max;
			if(n < 0) {
				return n + max;
			}
			else {
				return n;
			}
		}
	};
	__ks_Number._im_mod = function(that, ...args) {
		return __ks_Number.__ks_func_mod_rt(that, args);
	};
	__ks_Number.__ks_func_mod_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_Number.__ks_func_mod_0.call(that, args[0]);
			}
		}
		if(that.mod) {
			return that.mod(...args);
		}
		throw Helper.badArgs();
	};
	console.log(__ks_Number.__ks_func_mod_0.call(42, 3));
};
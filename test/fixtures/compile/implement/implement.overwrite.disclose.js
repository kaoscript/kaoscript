const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Date = {};
	__ks_Date.__ks_func_setDate_1 = function(value) {
		this.setDate(value);
		return this;
	};
	__ks_Date._im_setDate = function(that, ...args) {
		return __ks_Date.__ks_func_setDate_rt(that, args);
	};
	__ks_Date.__ks_func_setDate_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_Date.__ks_func_setDate_1.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		Date,
		__ks_Date
	};
};
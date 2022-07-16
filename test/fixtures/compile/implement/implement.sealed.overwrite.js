const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	var __ks_Date = {};
	__ks_Date.__ks_func_getHours_1 = function() {
		return this.getUTCHours();
	};
	__ks_Date.__ks_func_setHours_1 = function(hours) {
		this.setUTCHours(hours);
		return this;
	};
	__ks_Date._im_getHours = function(that, ...args) {
		return __ks_Date.__ks_func_getHours_rt(that, args);
	};
	__ks_Date.__ks_func_getHours_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Date.__ks_func_getHours_1.call(that);
		}
		throw Helper.badArgs();
	};
	__ks_Date._im_setHours = function(that, ...args) {
		return __ks_Date.__ks_func_setHours_rt(that, args);
	};
	__ks_Date.__ks_func_setHours_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_Date.__ks_func_setHours_1.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const d = new Date();
	expect(__ks_Date.__ks_func_setHours_1.call(d, 12)).to.equal(d);
	expect(__ks_Date.__ks_func_getHours_1.call(d)).to.equal(12);
	return {
		Date,
		__ks_Date
	};
};
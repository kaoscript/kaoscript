require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Date) {
	if(!Type.isValue(__ks_Date)) {
		var __ks_Date = require("./.import.xample1.core.ks.np51g.ksb")().__ks_Date;
	}
	__ks_Date.__ks_func_getTime_1 = function() {
		return 0;
	};
	__ks_Date.__ks_func_getEpochTime_1 = function() {
		return __ks_Date.__ks_func_getTime_1.call(this);
	};
	__ks_Date._im_getTime = function(that, ...args) {
		return __ks_Date.__ks_func_getTime_rt(that, args);
	};
	__ks_Date.__ks_func_getTime_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Date.__ks_func_getTime_1.call(that);
		}
		throw Helper.badArgs();
	};
	__ks_Date.__ks_func_getEpochTime_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Date.__ks_func_getEpochTime_1.call(that);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Date
	};
};
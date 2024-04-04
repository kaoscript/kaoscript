const {Helper} = require("@kaoscript/runtime");
module.exports = function(__ks_Date) {
	if(!__ks_Date) {
		__ks_Date = {};
	}
	__ks_Date.__ks_func_getEpochTime_0 = function() {
		return this.getTime();
	};
	__ks_Date._im_getEpochTime = function(that, ...args) {
		return __ks_Date.__ks_func_getEpochTime_rt(that, args);
	};
	__ks_Date.__ks_func_getEpochTime_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Date.__ks_func_getEpochTime_0.call(that);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Date
	};
};
const {Helper} = require("@kaoscript/runtime");
module.exports = function(__ks_Date) {
	if(!__ks_Date) {
		__ks_Date = {};
	}
	__ks_Date.__ks_func_fromGenesis_0 = function() {
	};
	__ks_Date._im_fromGenesis = function(that, ...args) {
		return __ks_Date.__ks_func_fromGenesis_rt(that, args);
	};
	__ks_Date.__ks_func_fromGenesis_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Date.__ks_func_fromGenesis_0.call(that);
		}
		if(that.fromGenesis) {
			return that.fromGenesis(...args);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Date
	};
};
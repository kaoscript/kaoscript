const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Date) {
	if(!Type.isValue(__ks_Date)) {
		__ks_Date = {};
	}
	__ks_Date.__ks_func_toString_1 = function() {
		return this.toISOString();
	};
	__ks_Date._im_toString = function(that, ...args) {
		return __ks_Date.__ks_func_toString_rt(that, args);
	};
	__ks_Date.__ks_func_toString_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Date.__ks_func_toString_2.call(that);
		}
		throw Helper.badArgs();
	};
	__ks_Date.__ks_func_toString_2 = function() {
		return __ks_Date.__ks_func_toString_1.apply(this);
	};
	__ks_Date.__ks_func_toString_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Date.__ks_func_toString_2.call(that);
		}
		throw Helper.badArgs();
	};
};
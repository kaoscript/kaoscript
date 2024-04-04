const {Helper} = require("@kaoscript/runtime");
module.exports = function(__ks_Array) {
	if(!__ks_Array) {
		__ks_Array = {};
	}
	__ks_Array.__ks_func_copy_0 = function() {
		return this;
	};
	__ks_Array._im_copy = function(that, ...args) {
		return __ks_Array.__ks_func_copy_rt(that, args);
	};
	__ks_Array.__ks_func_copy_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Array.__ks_func_copy_0.call(that);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Array
	};
};
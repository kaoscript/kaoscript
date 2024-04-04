const {Helper} = require("@kaoscript/runtime");
module.exports = function(__ks_String) {
	if(!__ks_String) {
		__ks_String = {};
	}
	__ks_String.__ks_func_clean_0 = function() {
		return this.replace(/\s+/g, " ").trim();
	};
	__ks_String._im_clean = function(that, ...args) {
		return __ks_String.__ks_func_clean_rt(that, args);
	};
	__ks_String.__ks_func_clean_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_clean_0.call(that);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_String
	};
};
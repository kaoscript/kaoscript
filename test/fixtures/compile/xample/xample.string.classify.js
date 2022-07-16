const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = {};
	__ks_String.__ks_func_capitalizeWords_0 = function() {
		return this;
	};
	__ks_String.__ks_func_classify_0 = function() {
		return __ks_String.__ks_func_capitalizeWords_0.call(this.replace(/[-_]/g, " ").replace(/([A-Z])/g, " $1")).replace(/\s/g, "");
	};
	__ks_String._im_capitalizeWords = function(that, ...args) {
		return __ks_String.__ks_func_capitalizeWords_rt(that, args);
	};
	__ks_String.__ks_func_capitalizeWords_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_capitalizeWords_0.call(that);
		}
		throw Helper.badArgs();
	};
	__ks_String._im_classify = function(that, ...args) {
		return __ks_String.__ks_func_classify_rt(that, args);
	};
	__ks_String.__ks_func_classify_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_classify_0.call(that);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_String
	};
};
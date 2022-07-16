const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Boolean = {};
	__ks_Boolean.__ks_func_toInt_0 = function() {
		return this ? 1 : 0;
	};
	__ks_Boolean._im_toInt = function(that, ...args) {
		return __ks_Boolean.__ks_func_toInt_rt(that, args);
	};
	__ks_Boolean.__ks_func_toInt_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Boolean.__ks_func_toInt_0.call(that);
		}
		if(that.toInt) {
			return that.toInt(...args);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Boolean
	};
};
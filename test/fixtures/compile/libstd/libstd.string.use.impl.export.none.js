const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_String = {};
	__ks_String.__ks_func_lower_0 = function() {
		return this.toLowerCase();
	};
	__ks_String.__ks_func_toFloat_0 = function() {
		return parseFloat(this);
	};
	__ks_String.__ks_func_toInt_0 = function(base) {
		if(base === void 0 || base === null) {
			base = 10;
		}
		return parseInt(this, base);
	};
	__ks_String._im_lower = function(that, ...args) {
		return __ks_String.__ks_func_lower_rt(that, args);
	};
	__ks_String.__ks_func_lower_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_lower_0.call(that);
		}
		throw Helper.badArgs();
	};
	__ks_String._im_toFloat = function(that, ...args) {
		return __ks_String.__ks_func_toFloat_rt(that, args);
	};
	__ks_String.__ks_func_toFloat_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_toFloat_0.call(that);
		}
		throw Helper.badArgs();
	};
	__ks_String._im_toInt = function(that, ...args) {
		return __ks_String.__ks_func_toInt_rt(that, args);
	};
	__ks_String.__ks_func_toInt_rt = function(that, args) {
		if(args.length <= 1) {
			return __ks_String.__ks_func_toInt_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_String
	};
};
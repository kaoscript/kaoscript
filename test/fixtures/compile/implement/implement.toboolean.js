const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Boolean = {};
	var __ks_String = {};
	__ks_Boolean.__ks_func_toBoolean_0 = function() {
		return this;
	};
	__ks_Boolean._im_toBoolean = function(that, ...args) {
		return __ks_Boolean.__ks_func_toBoolean_rt(that, args);
	};
	__ks_Boolean.__ks_func_toBoolean_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Boolean.__ks_func_toBoolean_0.call(that);
		}
		if(that.toBoolean) {
			return that.toBoolean(...args);
		}
		throw Helper.badArgs();
	};
	__ks_String.__ks_func_toBoolean_0 = function() {
		return /^(?:true|1|on|yes)$/i.test(this);
	};
	__ks_String._im_toBoolean = function(that, ...args) {
		return __ks_String.__ks_func_toBoolean_rt(that, args);
	};
	__ks_String.__ks_func_toBoolean_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_toBoolean_0.call(that);
		}
		if(that.toBoolean) {
			return that.toBoolean(...args);
		}
		throw Helper.badArgs();
	};
	console.log(__ks_Boolean.__ks_func_toBoolean_0.call(true));
	console.log(__ks_String.__ks_func_toBoolean_0.call("true"));
};
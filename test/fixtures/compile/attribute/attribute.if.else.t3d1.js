const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = {};
	__ks_String.__ks_func_endsWith_0 = function(value) {
		return (this.length >= value.length) && (this.slice(this.length - value.length) === value);
	};
	__ks_String._im_endsWith = function(that, ...args) {
		return __ks_String.__ks_func_endsWith_rt(that, args);
	};
	__ks_String.__ks_func_endsWith_rt = function(that, args) {
		var t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_String.__ks_func_endsWith_0.call(that, args[0]);
			}
		}
		if(that.endsWith) {
			return that.endsWith(...args);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_String
	};
};
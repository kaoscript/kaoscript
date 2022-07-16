const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = {};
	__ks_String.__ks_func_toInt_0 = function(base) {
		if(base === void 0 || base === null) {
			base = 10;
		}
		return parseInt(this, base);
	};
	__ks_String._im_toInt = function(that, ...args) {
		return __ks_String.__ks_func_toInt_rt(that, args);
	};
	__ks_String.__ks_func_toInt_rt = function(that, args) {
		if(args.length <= 1) {
			return __ks_String.__ks_func_toInt_0.call(that, args[0]);
		}
		if(that.toInt) {
			return that.toInt(...args);
		}
		throw Helper.badArgs();
	};
	console.log(__ks_String.__ks_func_toInt_0.call("42"));
};
require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = require("../require/.require.alt.roe.array.ks.ri6kvh.ksb")({}).__ks_Array;
	__ks_Array.__ks_func_foobar_0 = function() {
		return 42;
	};
	__ks_Array._im_foobar = function(that, ...args) {
		return __ks_Array.__ks_func_foobar_rt(that, args);
	};
	__ks_Array.__ks_func_foobar_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Array.__ks_func_foobar_0.call(that);
		}
		if(that.foobar) {
			return that.foobar(...args);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Array
	};
};
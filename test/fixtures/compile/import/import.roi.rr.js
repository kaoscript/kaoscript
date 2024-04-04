require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function(__ks_Array) {
	if(!__ks_Array) {
		var __ks_Array = require("../require/.require.alt.roi.system.ks.np51g.ksb")().__ks_Array;
	}
	__ks_Array.__ks_func_foo_0 = function() {
		return 42;
	};
	__ks_Array._im_foo = function(that, ...args) {
		return __ks_Array.__ks_func_foo_rt(that, args);
	};
	__ks_Array.__ks_func_foo_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Array.__ks_func_foo_0.call(that);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Array
	};
};
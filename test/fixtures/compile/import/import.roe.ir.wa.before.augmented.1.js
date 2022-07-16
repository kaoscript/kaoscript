const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Array) {
	__ks_Array.__ks_func_copy_0 = function(x) {
		return x;
	};
	__ks_Array._im_copy = function(that, ...args) {
		return __ks_Array.__ks_func_copy_rt(that, args);
	};
	__ks_Array.__ks_func_copy_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_Array.__ks_func_copy_0.call(that, args[0]);
			}
		}
		if(that.copy) {
			return that.copy(...args);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Array
	};
};
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Number = {};
	__ks_Number.__ks_func_repeat_0 = function(fn, bind = null) {
	};
	__ks_Number._im_repeat = function(that, ...args) {
		return __ks_Number.__ks_func_repeat_rt(that, args);
	};
	__ks_Number.__ks_func_repeat_rt = function(that, args) {
		const t0 = Type.isFunction;
		if(args.length >= 1 && args.length <= 2) {
			if(t0(args[0])) {
				return __ks_Number.__ks_func_repeat_0.call(that, args[0], args[1]);
			}
		}
		if(that.repeat) {
			return that.repeat(...args);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Number
	};
};
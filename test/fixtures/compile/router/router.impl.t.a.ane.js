const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Date = {};
	__ks_Date.__ks_func_equals_0 = function(value) {
		return this.getTime() === value.getTime();
	};
	__ks_Date.__ks_func_equals_1 = function(value) {
		return false;
	};
	__ks_Date.__ks_func_equals_2 = function(value) {
		if(value === void 0) {
			value = null;
		}
		return false;
	};
	__ks_Date._im_equals = function(that, ...args) {
		return __ks_Date.__ks_func_equals_rt(that, args);
	};
	__ks_Date.__ks_func_equals_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Date);
		const t1 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_Date.__ks_func_equals_0.call(that, args[0]);
			}
			if(t1(args[0])) {
				return __ks_Date.__ks_func_equals_1.call(that, args[0]);
			}
			return __ks_Date.__ks_func_equals_2.call(that, args[0]);
		}
		if(that.equals) {
			return that.equals(...args);
		}
		throw Helper.badArgs();
	};
};
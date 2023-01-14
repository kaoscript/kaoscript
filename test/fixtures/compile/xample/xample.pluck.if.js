const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = {};
	__ks_Array.__ks_func_pluck_0 = function(name) {
		let result = [];
		let value;
		for(let __ks_1 = 0, __ks_0 = this.length, item; __ks_1 < __ks_0; ++__ks_1) {
			item = this[__ks_1];
			if(Type.isValue(item) && Type.isValue(item[name]) ? (value = item[name], true) : false) {
				if(Type.isFunction(value)) {
					let __ks_2;
					if(Type.isValue(__ks_2 = value.call(item)) ? (value = __ks_2, true) : false) {
						result.push(value);
					}
				}
				else {
					result.push(value);
				}
			}
		}
		return result;
	};
	__ks_Array._im_pluck = function(that, ...args) {
		return __ks_Array.__ks_func_pluck_rt(that, args);
	};
	__ks_Array.__ks_func_pluck_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_Array.__ks_func_pluck_0.call(that, args[0]);
			}
		}
		if(that.pluck) {
			return that.pluck(...args);
		}
		throw Helper.badArgs();
	};
};
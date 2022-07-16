const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = {};
	var __ks_String = {};
	__ks_String.__ks_func_replaceAll_0 = function(find, replacement) {
		if(find.length === 0) {
			return this.valueOf();
		}
		if(Operator.lte(find.length, 3)) {
			return this.split(find).join(replacement);
		}
		else {
			return this.replace(new RegExp(find.escapeRegex(), "g"), replacement);
		}
	};
	__ks_String._im_replaceAll = function(that, ...args) {
		return __ks_String.__ks_func_replaceAll_rt(that, args);
	};
	__ks_String.__ks_func_replaceAll_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return __ks_String.__ks_func_replaceAll_0.call(that, args[0], args[1]);
			}
		}
		if(that.replaceAll) {
			return that.replaceAll(...args);
		}
		throw Helper.badArgs();
	};
};
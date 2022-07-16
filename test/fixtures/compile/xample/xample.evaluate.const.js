const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = {};
	__ks_String.__ks_func_evaluate_0 = function() {
		const value = this.trim();
		if(__ks_String.__ks_func_startsWith_0.call(value, "function") || __ks_String.__ks_func_startsWith_0.call(value, "{")) {
			return eval("(function(){return " + value + ";})()");
		}
		else {
			return eval(value);
		}
	};
	__ks_String.__ks_func_startsWith_0 = function(value) {
		return Operator.gte(this.length, value.length) && (this.slice(0, value.length) === value);
	};
	__ks_String._im_evaluate = function(that, ...args) {
		return __ks_String.__ks_func_evaluate_rt(that, args);
	};
	__ks_String.__ks_func_evaluate_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_evaluate_0.call(that);
		}
		if(that.evaluate) {
			return that.evaluate(...args);
		}
		throw Helper.badArgs();
	};
	__ks_String._im_startsWith = function(that, ...args) {
		return __ks_String.__ks_func_startsWith_rt(that, args);
	};
	__ks_String.__ks_func_startsWith_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_String.__ks_func_startsWith_0.call(that, args[0]);
			}
		}
		if(that.startsWith) {
			return that.startsWith(...args);
		}
		throw Helper.badArgs();
	};
};
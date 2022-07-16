const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Number, __ks_String) {
	if(!Type.isValue(__ks_Number)) {
		__ks_Number = {};
	}
	if(!Type.isValue(__ks_String)) {
		__ks_String = {};
	}
	__ks_String.__ks_func_toFloat_0 = function() {
		return parseFloat(this);
	};
	__ks_String.__ks_func_toInt_0 = function(base) {
		if(base === void 0 || base === null) {
			base = 10;
		}
		return parseInt(this, base);
	};
	__ks_String._im_toFloat = function(that, ...args) {
		return __ks_String.__ks_func_toFloat_rt(that, args);
	};
	__ks_String.__ks_func_toFloat_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_toFloat_0.call(that);
		}
		if(that.toFloat) {
			return that.toFloat(...args);
		}
		throw Helper.badArgs();
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
	return {
		__ks_Number,
		__ks_String
	};
};
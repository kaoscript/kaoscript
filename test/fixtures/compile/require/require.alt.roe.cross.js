var Type = require("@kaoscript/runtime").Type;
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
	__ks_String._im_toFloat = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_String.__ks_func_toFloat_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_String._im_toInt = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length >= 0 && args.length <= 1) {
			return __ks_String.__ks_func_toInt_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		__ks_Number: __ks_Number,
		__ks_String: __ks_String
	};
};
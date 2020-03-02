require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function(__ks_Date) {
	if(!Type.isValue(__ks_Date)) {
		var __ks_Date = require("./import.xample1.core.ks")().__ks_Date;
	}
	__ks_Date.__ks_func_getTime_1 = function() {
		return 0;
	};
	__ks_Date.__ks_func_getEpochTime_1 = function() {
		return __ks_Date._im_getTime(this);
	};
	__ks_Date._im_getTime = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Date.__ks_func_getTime_1.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_Date._im_getEpochTime = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Date.__ks_func_getEpochTime_1.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		__ks_Date: __ks_Date
	};
};
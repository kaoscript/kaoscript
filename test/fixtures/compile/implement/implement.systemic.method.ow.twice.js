var Type = require("@kaoscript/runtime").Type;
module.exports = function(__ks_Date) {
	if(!Type.isValue(__ks_Date)) {
		__ks_Date = {};
	}
	__ks_Date.__ks_func_toString_1 = function() {
		return this.toISOString();
	};
	__ks_Date._im_toString = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Date.__ks_func_toString_2.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_Date.__ks_func_toString_2 = function() {
		return __ks_Date.__ks_func_toString_1.apply(this);
	};
	__ks_Date._im_toString = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Date.__ks_func_toString_2.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
};
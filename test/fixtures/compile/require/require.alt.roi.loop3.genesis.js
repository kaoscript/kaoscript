var Type = require("@kaoscript/runtime").Type;
function __ks_require(__ks_0, __ks___ks_0) {
	var req = [];
	if(Type.isValue(__ks_0)) {
		req.push(__ks_0, __ks___ks_0);
	}
	else {
		req.push(Date, typeof __ks_Date === "undefined" ? {} : __ks_Date);
	}
	return req;
}
module.exports = function(__ks_0, __ks___ks_0) {
	var [Date, __ks_Date] = __ks_require(__ks_0, __ks___ks_0);
	__ks_Date.__ks_func_fromGenesis_0 = function() {
	};
	__ks_Date._im_fromGenesis = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Date.__ks_func_fromGenesis_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		Date: Date,
		__ks_Date: __ks_Date
	};
};
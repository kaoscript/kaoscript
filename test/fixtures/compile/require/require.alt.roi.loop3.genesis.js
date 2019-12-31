var Type = require("@kaoscript/runtime").Type;
module.exports = function(__ks_Date) {
	if(!Type.isValue(__ks_Date)) {
		__ks_Date = {};
	}
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
		__ks_Date: __ks_Date
	};
};
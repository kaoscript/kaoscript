require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function(__ks_Date) {
	if(!Type.isValue(__ks_Date)) {
		var __ks_Date = require("./require.alt.roi.loop3.genesis.ks")().__ks_Date;
	}
	var __ks_Date = require("./require.alt.roi.loop3.augment.ks")(__ks_Date).__ks_Date;
	__ks_Date.__ks_func_fromSpecial_0 = function() {
	};
	__ks_Date._im_fromSpecial = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Date.__ks_func_fromSpecial_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	const d = __ks_Date.new(2000, 1, 20, 3, 45, 6, 789);
	return {
		__ks_Date: __ks_Date
	};
};
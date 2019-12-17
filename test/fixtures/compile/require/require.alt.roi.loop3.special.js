require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function(Date, __ks_Date) {
	if(!Type.isValue(Date)) {
		var {Date, __ks_Date} = require("./require.alt.roi.loop3.genesis.ks")();
	}
	var {Date, __ks_Date} = require("./require.alt.roi.loop3.augment.ks")(Date, __ks_Date);
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
		Date: Date,
		__ks_Date: __ks_Date
	};
};
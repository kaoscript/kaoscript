require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Date) {
	if(!Type.isValue(__ks_Date)) {
		var __ks_Date = require("./.require.alt.roi.loop3.genesis.ks.1runl5l.ksb")().__ks_Date;
	}
	var __ks_Date = require("./.require.alt.roi.loop3.augment.ks.bxmt52.ksb")(__ks_Date).__ks_Date;
	__ks_Date.__ks_func_fromSpecial_0 = function() {
	};
	__ks_Date._im_fromSpecial = function(that, ...args) {
		return __ks_Date.__ks_func_fromSpecial_rt(that, args);
	};
	__ks_Date.__ks_func_fromSpecial_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Date.__ks_func_fromSpecial_0.call(that);
		}
		throw Helper.badArgs();
	};
	const d = __ks_Date.__ks_new_1(2000, 1, 20, 3, 45, 6, 789);
	return {
		__ks_Date
	};
};
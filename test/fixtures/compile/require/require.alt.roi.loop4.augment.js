require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function(__ks_Array, __ks_String) {
	if(!__ks_Array && !__ks_String) {
		var {__ks_Array, __ks_String} = require("./.require.alt.roi.loop4.genesis.ks.fpb9zp.ksb")();
	}
	else if(!(__ks_Array || __ks_String)) {
		throw Helper.badRequirements();
	}
	return {
		__ks_Array,
		__ks_String
	};
};
require("kaoscript/register");
const {Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Array, __ks_Object, clone) {
	var __ks_0_valuable = Type.isValue(__ks_Array);
	var __ks_1_valuable = Type.isValue(__ks_Object);
	var __ks_2_valuable = Type.isValue(clone);
	if(!__ks_0_valuable || !__ks_1_valuable || !__ks_2_valuable) {
		var __ks__ = require("./.require.alt.roi.loop1.genesis.ks.fpb9zp.ksb")();
		if(!__ks_0_valuable) {
			__ks_Array = __ks__.__ks_Array;
		}
		if(!__ks_1_valuable) {
			__ks_Object = __ks__.__ks_Object;
		}
		if(!__ks_2_valuable) {
			clone = __ks__.clone;
		}
	}
	var {__ks_Array, __ks_Object} = require("./.require.alt.roi.loop1.augment.ks.jane0k.ksb")(__ks_Array, __ks_Object, clone);
};
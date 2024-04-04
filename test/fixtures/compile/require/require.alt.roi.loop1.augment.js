require("kaoscript/register");
const {OBJ, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Array, __ks_Object, clone) {
	var __ks_0_valuable = Type.isValue(clone);
	if(!__ks_Array || !__ks_Object || !__ks_0_valuable) {
		var __ks__ = require("./.require.alt.roi.loop1.genesis.ks.fpb9zp.ksb")();
		if(!__ks_Array) {
			__ks_Array = __ks__.__ks_Array;
		}
		if(!__ks_Object) {
			__ks_Object = __ks__.__ks_Object;
		}
		if(!__ks_0_valuable) {
			clone = __ks__.clone;
		}
	}
	return {
		__ks_Array,
		__ks_Object
	};
};
require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function(__ks_Array, __ks_String) {
	var __ks_0_valuable = Type.isValue(__ks_Array);
	var __ks_1_valuable = Type.isValue(__ks_String);
	if(!__ks_0_valuable || !__ks_1_valuable) {
		var __ks__ = require("./require.alt.roi.loop4.augment.ks")();
		if(!__ks_0_valuable) {
			__ks_Array = __ks__.__ks_Array;
		}
		if(!__ks_1_valuable) {
			__ks_String = __ks__.__ks_String;
		}
	}
};
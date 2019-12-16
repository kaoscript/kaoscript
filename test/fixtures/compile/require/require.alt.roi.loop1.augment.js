require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function(Array, __ks_Array, Object, __ks_Object, clone) {
	var __ks_0_valuable = Type.isValue(Array);
	var __ks_1_valuable = Type.isValue(Object);
	var __ks_2_valuable = Type.isValue(clone);
	if(!__ks_0_valuable || !__ks_1_valuable || !__ks_2_valuable) {
		var __ks__ = require("./require.alt.roi.loop1.genesis.ks")();
		if(!__ks_0_valuable) {
			Array = __ks__.Array;
			__ks_Array = __ks__.__ks_Array;
		}
		if(!__ks_1_valuable) {
			Object = __ks__.Object;
			__ks_Object = __ks__.__ks_Object;
		}
		clone = __ks_2_valuable ? clone : __ks__.clone;
	}
	return {
		Array: Array,
		__ks_Array: __ks_Array,
		Object: Object,
		__ks_Object: __ks_Object
	};
};
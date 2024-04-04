const {OBJ, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Array, __ks_Object, __ks_String) {
	if(!Type.isValue(__ks_Array)) {
		__ks_Array = {};
	}
	if(!Type.isValue(__ks_Object)) {
		__ks_Object = {};
	}
	if(!Type.isValue(__ks_String)) {
		__ks_String = {};
	}
	return {
		__ks_Array: {},
		__ks_Object: {},
		__ks_String: {}
	};
};
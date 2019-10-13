var {Dictionary, Type} = require("@kaoscript/runtime");
function __ks_require(__ks_0, __ks___ks_0, __ks_1, __ks___ks_1, __ks_2, __ks___ks_2) {
	var req = [];
	if(Type.isValue(Array)) {
		req.push(Array, typeof __ks_Array === "undefined" ? {} : __ks_Array);
	}
	else {
		req.push(__ks_0, __ks___ks_0);
	}
	if(Type.isValue(Dictionary)) {
		req.push(Dictionary, typeof __ks_Dictionary === "undefined" ? {} : __ks_Dictionary);
	}
	else {
		req.push(__ks_1, __ks___ks_1);
	}
	if(Type.isValue(String)) {
		req.push(String, typeof __ks_String === "undefined" ? {} : __ks_String);
	}
	else {
		req.push(__ks_2, __ks___ks_2);
	}
	return req;
}
module.exports = function(__ks_0, __ks___ks_0, __ks_1, __ks___ks_1, __ks_2, __ks___ks_2) {
	var [Array, __ks_Array, Dictionary, __ks_Dictionary, String, __ks_String] = __ks_require(__ks_0, __ks___ks_0, __ks_1, __ks___ks_1, __ks_2, __ks___ks_2);
	return {
		Array: Array,
		__ks_Array: __ks_Array,
		Dictionary: Dictionary,
		__ks_Dictionary: __ks_Dictionary,
		String: String,
		__ks_String: __ks_String
	};
};
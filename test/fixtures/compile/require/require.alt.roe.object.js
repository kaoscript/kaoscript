var Type = require("@kaoscript/runtime").Type;
function __ks_require(__ks_0, __ks___ks_0) {
	var req = [];
	if(Type.isValue(__ks_0)) {
		req.push(__ks_0, __ks___ks_0);
	}
	else {
		req.push(Object, typeof __ks_Object === "undefined" ? {} : __ks_Object);
	}
	return req;
}
module.exports = function(__ks_0, __ks___ks_0) {
	var [Object, __ks_Object] = __ks_require(__ks_0, __ks___ks_0);
	return {
		Object: Object,
		__ks_Object: __ks_Object
	};
};
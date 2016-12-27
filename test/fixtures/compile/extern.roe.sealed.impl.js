var Type = require("@kaoscript/runtime").Type;
function __ks_require(__ks_0, __ks___ks_0, __ks_1, __ks___ks_1) {
	var req = [];
	if(Type.isValue(__ks_0)) {
		req.push(__ks_0, __ks___ks_0);
	}
	else {
		req.push(Number, typeof __ks_Number === "undefined" ? {} : __ks_Number);
	}
	if(Type.isValue(__ks_1)) {
		req.push(__ks_1, __ks___ks_1);
	}
	else {
		req.push(Math, typeof __ks_Math === "undefined" ? {} : __ks_Math);
	}
	return req;
}
module.exports = function(__ks_0, __ks___ks_0, __ks_1, __ks___ks_1) {
	var [Number, __ks_Number, Math, __ks_Math] = __ks_require(__ks_0, __ks___ks_0, __ks_1, __ks___ks_1);
	__ks_Math.pi = Math.PI;
	__ks_Math.foo = function() {
		return Math.PI;
	};
	__ks_Math.pi;
	__ks_Math.foo();
}
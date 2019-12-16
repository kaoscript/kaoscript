var Type = require("@kaoscript/runtime").Type;
function __ks_require(__ks_0, __ks___ks_0) {
	var req = [];
	if(Type.isValue(__ks_0)) {
		req.push(__ks_0, __ks___ks_0);
	}
	else {
		req.push(Number, typeof __ks_Number === "undefined" ? {} : __ks_Number);
	}
	return req;
}
module.exports = function(__ks_0, __ks___ks_0) {
	var [Number, __ks_Number] = __ks_require(__ks_0, __ks___ks_0);
	return {
		Number: Number,
		__ks_Number: __ks_Number
	};
};
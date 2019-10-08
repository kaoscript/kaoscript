var {Dictionary, Type} = require("@kaoscript/runtime");
function __ks_require(__ks_0, __ks___ks_0) {
	var req = [];
	if(Type.isValue(__ks_0)) {
		req.push(__ks_0, __ks___ks_0);
	}
	else {
		req.push(Dictionary, typeof __ks_Dictionary === "undefined" ? {} : __ks_Dictionary);
	}
	return req;
}
module.exports = function(__ks_0, __ks___ks_0) {
	var [Dictionary, __ks_Dictionary] = __ks_require(__ks_0, __ks___ks_0);
};
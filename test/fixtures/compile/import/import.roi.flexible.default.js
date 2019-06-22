require("kaoscript/register");
function __ks_require(__ks_0, __ks_1, __ks___ks_1) {
	var req = [];
	var __ks_0_valuable = Type.isValue(__ks_0);
	var __ks_1_valuable = Type.isValue(__ks_1);
	if(!__ks_0_valuable || !__ks_1_valuable) {
		var {Foobar, Array, __ks_Array} = require("./import.roi.flexible.module.ks")();
		req.push(__ks_0_valuable ? __ks_0 : Foobar);
		if(__ks_1_valuable) {
			req.push(__ks_1, __ks___ks_1);
		}
		else {
			req.push(Array, __ks_Array);
		}
	}
	else {
		req.push(__ks_0, __ks_1, __ks___ks_1);
	}
	return req;
}
module.exports = function(__ks_0, __ks_1, __ks___ks_1) {
	var [Foobar, Array, __ks_Array] = __ks_require(__ks_0, __ks_1, __ks___ks_1);
};
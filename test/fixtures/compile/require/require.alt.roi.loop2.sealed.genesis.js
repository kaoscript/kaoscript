var Type = require("@kaoscript/runtime").Type;
module.exports = function(__ks_0, __ks___ks_0) {
	if(Type.isValue(__ks_0)) {
		Number = __ks_0;
		__ks_Number = __ks___ks_0;
	}
	else {
		__ks_Number = {};
	}
	return {
		Number: Number,
		__ks_Number: __ks_Number
	};
};
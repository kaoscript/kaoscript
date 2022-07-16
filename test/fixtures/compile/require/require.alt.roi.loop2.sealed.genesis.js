const {Type} = require("@kaoscript/runtime");
module.exports = function(__ks_0, __ks___ks_0) {
	if(Type.isValue(__ks_0)) {
		Number = __ks_0;
		__ks_Number = __ks___ks_0;
	}
	else {
		__ks_Number = {};
	}
	return {
		Number,
		__ks_Number
	};
};
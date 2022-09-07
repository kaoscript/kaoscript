const {Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Date, __ks_Math) {
	if(!Type.isValue(__ks_Date)) {
		__ks_Date = {};
	}
	if(!Type.isValue(__ks_Math)) {
		__ks_Math = {};
	}
	return {
		__ks_Date,
		__ks_Math
	};
};
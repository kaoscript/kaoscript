var Type = require("@kaoscript/runtime").Type;
module.exports = function(__ks_Number) {
	if(!Type.isValue(__ks_Number)) {
		__ks_Number = {};
	}
	return {
		__ks_Number: __ks_Number
	};
};
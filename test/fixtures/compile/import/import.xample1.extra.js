require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function(__ks_Date) {
	if(!Type.isValue(__ks_Date)) {
		var __ks_Date = require("./import.xample1.core.ks")().__ks_Date;
	}
	var __ks_Date = require("./import.xample1.augmented.ks")(__ks_Date).__ks_Date;
	return {
		__ks_Date: __ks_Date
	};
};
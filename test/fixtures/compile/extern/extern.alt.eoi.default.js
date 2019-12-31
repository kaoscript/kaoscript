require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	if(!Type.isValue(__ks_Array)) {
		var __ks_Array = require("../_/_array.ks")().__ks_Array;
	}
	return {
		__ks_Array: __ks_Array
	};
};
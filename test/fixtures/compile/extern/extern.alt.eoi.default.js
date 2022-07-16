require("kaoscript/register");
const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	if(!Type.isValue(__ks_Array)) {
		var __ks_Array = require("../_/._array.ks.j5k8r9.ksb")().__ks_Array;
	}
	return {
		__ks_Array
	};
};
require("kaoscript/register");
const {Type} = require("@kaoscript/runtime");
module.exports = function(Foobar, __ks_Array) {
	var __ks_0_valuable = Type.isValue(Foobar);
	if(!__ks_0_valuable || !__ks_Array) {
		var __ks__ = require("./.import.roi.flexible.module.ks.j5k8r9.ksb")();
		if(!__ks_0_valuable) {
			Foobar = __ks__.Foobar;
		}
		if(!__ks_Array) {
			__ks_Array = __ks__.__ks_Array;
		}
	}
};
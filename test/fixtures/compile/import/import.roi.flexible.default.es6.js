require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function(Foobar, Array, __ks_Array) {
	var __ks_0_valuable = Type.isValue(Foobar);
	var __ks_1_valuable = Type.isValue(Array);
	if(!__ks_0_valuable || !__ks_1_valuable) {
		var {__ks_0, __ks_1, __ks___ks_1} = require("./import.roi.flexible.module.ks")();
		Foobar = __ks_0_valuable ? Foobar : __ks_0;
		if(!__ks_1_valuable) {
			Array = __ks_1;
			__ks_Array = __ks___ks_1;
		}
	}
};
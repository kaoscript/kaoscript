require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(Foobar, __ks_Array) {
	var __ks_0_valuable = Type.isValue(Foobar);
	if(!__ks_0_valuable && !__ks_Array) {
		var {Foobar, __ks_Array} = require("./.import.roi.flexible.module.ks.j5k8r9.ksb")();
	}
	else if(!(__ks_0_valuable || __ks_Array)) {
		throw Helper.badRequirements();
	}
};
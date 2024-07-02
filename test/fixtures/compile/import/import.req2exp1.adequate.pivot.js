require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(Foobar, Quxbaz) {
	var __ks_0_valuable = Type.isValue(Foobar);
	var __ks_1_valuable = Type.isValue(Quxbaz);
	if(!__ks_0_valuable && !__ks_1_valuable) {
		var {Foobar, Quxbaz} = require("./.import.req2exp1.core.ks.j5k8r9.ksb")();
	}
	else if(!(__ks_0_valuable || __ks_1_valuable)) {
		throw Helper.badRequirements();
	}
	return {
		Foobar,
		Quxbaz
	};
};
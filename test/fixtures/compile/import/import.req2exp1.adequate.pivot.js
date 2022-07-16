require("kaoscript/register");
const {Type} = require("@kaoscript/runtime");
module.exports = function(Foobar, Quxbaz) {
	var __ks_0_valuable = Type.isValue(Foobar);
	var __ks_1_valuable = Type.isValue(Quxbaz);
	if(!__ks_0_valuable || !__ks_1_valuable) {
		var __ks__ = require("./.import.req2exp1.core.ks.j5k8r9.ksb")();
		if(!__ks_0_valuable) {
			Foobar = __ks__.Foobar;
		}
		if(!__ks_1_valuable) {
			Quxbaz = __ks__.Quxbaz;
		}
	}
	return {
		Foobar,
		Quxbaz
	};
};
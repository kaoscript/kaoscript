require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Number = {};
	var __ks_Array = require("../require/.require.alt.roe.methods.ks.1runl5l.ksb")().__ks_Array;
	const a = Helper.newArrayRange(1, 10, 1, true, true);
	console.log(a.indexOf(5).toString());
	console.log(__ks_Array.__ks_func_pushUniq_0.call(a, [5]).indexOf(5).toString());
};
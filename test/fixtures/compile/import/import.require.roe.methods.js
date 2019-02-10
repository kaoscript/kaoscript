require("kaoscript/register");
var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var __ks_Number = {};
	var {Array, __ks_Array} = require("../require/require.alt.roe.methods.ks")();
	const a = Helper.newArrayRange(1, 10, 1, true, true);
	console.log(a.indexOf(5).toString());
	console.log(__ks_Array._im_pushUniq(a, 5).indexOf(5).toString());
};
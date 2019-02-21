require("kaoscript/register");
module.exports = function() {
	var __ks_Number = {};
	var __ks_Math = {};
	var {Number, __ks_Number, Math, __ks_Math} = require("../require/require.alt.roe.math.pi.default.ks")(Number, __ks_Number, Math, __ks_Math);
	console.log(Math.PI.toString());
	console.log(__ks_Number._im_round(Math.PI).toString());
};
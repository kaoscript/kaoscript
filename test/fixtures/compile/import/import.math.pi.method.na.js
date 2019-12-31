require("kaoscript/register");
module.exports = function() {
	var {__ks_Number, __ks_Math} = require("../require/require.alt.roe.math.pi.default.ks")();
	console.log(Math.PI.toString());
	console.log(__ks_Number._im_round(Math.PI).toString());
};
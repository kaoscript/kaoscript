require("kaoscript/register");
module.exports = function() {
	var {String, __ks_String} = require("../_/_string.ks")();
	var {Number, __ks_Number, String, __ks_String} = require("../require/require.alt.roe.cross.ks")(String, __ks_String);
	return {
		Number: Number,
		__ks_Number: __ks_Number,
		String: String,
		__ks_String: __ks_String
	};
};
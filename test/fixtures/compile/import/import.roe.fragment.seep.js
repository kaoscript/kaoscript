require("kaoscript/register");
module.exports = function(String, __ks_String) {
	var {Number, __ks_Number, String, __ks_String} = require("../require/require.alt.roe.cross.ks")(String, __ks_String);
	return {
		Number: Number,
		__ks_Number: __ks_Number,
		String: String,
		__ks_String: __ks_String
	};
};
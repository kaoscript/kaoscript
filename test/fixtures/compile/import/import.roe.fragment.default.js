require("kaoscript/register");
module.exports = function() {
	var __ks_String = require("../_/_string.ks")().__ks_String;
	var {__ks_Number, __ks_String} = require("../require/require.alt.roe.cross.ks")(__ks_String);
	return {
		__ks_Number: __ks_Number,
		__ks_String: __ks_String
	};
};
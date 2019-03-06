require("kaoscript/register");
module.exports = function() {
	var {foobar, String, __ks_String} = require("./import.roi.reference.export.ks")();
	return {
		foobar: foobar,
		String: String,
		__ks_String: __ks_String
	};
};
require("kaoscript/register");
module.exports = function() {
	var {foobar, __ks_String} = require("./import.roi.reference.export.ks")();
	return {
		foobar: foobar,
		__ks_String: __ks_String
	};
};
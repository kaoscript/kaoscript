require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function(foobar) {
	var {String, __ks_String} = require("../_/_string.ks")();
	if(!Type.isValue(foobar)) {
		var foobar = require("./import.argument.object.export.type.ks")().foobar;
	}
	return {
		foobar: foobar,
		String: String,
		__ks_String: __ks_String
	};
};
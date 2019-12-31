require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function(foobar) {
	var __ks_String = require("../_/_string.ks")().__ks_String;
	if(!Type.isValue(foobar)) {
		var foobar = require("./import.argument.object.export.type.ks")().foobar;
	}
	return {
		foobar: foobar,
		__ks_String: __ks_String
	};
};
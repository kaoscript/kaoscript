require("kaoscript/register");
const {Type} = require("@kaoscript/runtime");
module.exports = function(foobar) {
	var __ks_String = require("../_/._string.ks.j5k8r9.ksb")().__ks_String;
	if(!Type.isValue(foobar)) {
		var foobar = require("./.import.argument.object.export.type.ks.j5k8r9.ksb")().foobar;
	}
	return {
		foobar
	};
};
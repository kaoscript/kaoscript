require("kaoscript/register");
const {Type} = require("@kaoscript/runtime");
module.exports = function(foobar) {
	var __ks_String = require("../_/._string.ks.j5k8r9.ksb")().__ks_String;
	if(!Type.isValue(foobar)) {
		var foobar = require("./.import.argument.object.argsys.ks.s548vm.ksb")(__ks_String).foobar;
	}
	return {
		foobar,
		__ks_String
	};
};
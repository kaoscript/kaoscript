var __ks__ = require("@kaoscript/runtime");
var Helper = __ks__.Helper, Type = __ks__.Type;
module.exports = function() {
	function foobar() {
		return "foobar";
	}
	var x = foobar();
	if(Type.isValue(x)) {
		console.log(Helper.toString(x));
	}
	x = null;
	console.log(Helper.toString(x));
};
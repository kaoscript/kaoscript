var __ks__ = require("@kaoscript/runtime");
var Helper = __ks__.Helper, Type = __ks__.Type;
module.exports = function() {
	function foobar() {
		return "foobar";
	}
	var x = "barfoo";
	console.log(x);
	var __ks_x_1 = foobar();
	if(Type.isValue(__ks_x_1)) {
		console.log(Helper.toString(__ks_x_1));
	}
	console.log(x);
};
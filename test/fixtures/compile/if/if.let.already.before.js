var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		return "foobar";
	}
	let x = "foobar";
	let __ks_x_1;
	if(Type.isValue(__ks_x_1 = foobar())) {
		console.log("" + __ks_x_1);
	}
};
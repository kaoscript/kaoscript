var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		return "foobar";
	}
	let x;
	if(Type.isValue(x = foobar())) {
		console.log("" + x);
	}
	let __ks_x_1 = "foobar";
};
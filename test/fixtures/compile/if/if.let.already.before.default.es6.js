var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		return "foobar";
	}
	let x = "barfoo";
	console.log(x);
	let __ks_x_1 = foobar();
	if(Type.isValue(__ks_x_1)) {
		console.log("" + __ks_x_1);
	}
	console.log(x);
};
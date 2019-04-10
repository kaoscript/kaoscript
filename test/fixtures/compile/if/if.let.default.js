var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		return "foobar";
	}
	let x = foobar();
	if(Type.isValue(x)) {
		console.log("" + x);
	}
	x = foobar();
	if(Type.isValue(x)) {
		console.log("" + x);
	}
};
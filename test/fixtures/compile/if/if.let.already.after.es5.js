var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		return "foobar";
	}
	var x = foobar();
	if(Type.isValue(x)) {
		console.log("" + x);
	}
	x = null;
	console.log("" + x);
};
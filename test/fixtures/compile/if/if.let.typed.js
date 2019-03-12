var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		return "foobar";
	}
	let x;
	if(Type.isValue(x = foobar())) {
		console.log(x);
	}
};
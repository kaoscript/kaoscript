var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		return "foobar";
	}
	const x = foobar();
	if(Type.isValue(x)) {
		console.log(x);
	}
};
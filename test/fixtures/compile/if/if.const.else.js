var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		return null;
	}
	function quxbaz() {
		return "quxbaz";
	}
	let y;
	let x = foobar();
	if(Type.isValue(x)) {
		console.log("" + x);
	}
	else if(Type.isValue((y = quxbaz()))) {
		console.log("" + y);
	}
};
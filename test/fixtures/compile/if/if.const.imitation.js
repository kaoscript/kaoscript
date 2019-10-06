var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
	}
	function quxbaz() {
	}
	function corge() {
	}
	let x = foobar();
	if(Type.isValue(x)) {
	}
	else if(Type.isValue((x = quxbaz()))) {
	}
	else if(Type.isValue((x = corge()))) {
	}
};
var {Helper, Type} = require("@kaoscript/runtime");
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
		console.log(Helper.toString(x));
	}
	else if(Type.isValue((y = quxbaz()))) {
		console.log(Helper.toString(y));
	}
};
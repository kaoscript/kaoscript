var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return "foobar";
	}
	let x = foobar();
	if(Type.isValue(x)) {
		console.log(x);
	}
	x = null;
	console.log(Helper.toString(x));
};
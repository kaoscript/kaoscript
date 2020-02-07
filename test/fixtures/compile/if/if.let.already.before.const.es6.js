var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return "foobar";
	}
	const x = "barfoo";
	console.log(x);
	let __ks_x_1 = foobar();
	if(Type.isValue(__ks_x_1)) {
		console.log(Helper.toString(__ks_x_1));
	}
	console.log(x);
};
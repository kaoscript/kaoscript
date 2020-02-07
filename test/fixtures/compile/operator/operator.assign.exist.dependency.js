var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function xyz() {
		return "xyz";
	}
	let foo, __ks_0;
	if((Type.isValue(__ks_0 = xyz()) ? (foo = __ks_0, true) : false) && (Type.isValue(foo.bar) ? foo.bar.name === "xyz" : false) && Type.isValue(foo.qux)) {
		console.log(Helper.concatString("hello ", foo));
	}
};
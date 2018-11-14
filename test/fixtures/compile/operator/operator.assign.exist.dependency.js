var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function xyz() {
		return "xyz";
	}
	let foo, __ks_0;
	if((Type.isValue(__ks_0 = xyz()) ? (foo = __ks_0, true) : false) && (Type.isValue(foo.bar) ? foo.bar.name === "xyz" : false) && Type.isValue(foo.qux)) {
		console.log("hello " + foo);
	}
};
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let foo = function() {
		return "otto";
	};
	let bar, __ks_0;
	Type.isValue(__ks_0 = foo()) ? bar = __ks_0 : undefined;
	console.log(foo, bar);
}
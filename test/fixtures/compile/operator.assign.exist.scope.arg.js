var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo() {
		return this.message;
	}
	let bar, __ks_0;
	Type.isValue(__ks_0 = foo.call(context)) ? bar = __ks_0 : undefined;
	console.log(foo, bar);
}
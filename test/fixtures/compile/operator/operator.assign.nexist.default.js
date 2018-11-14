var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function qux() {
		let foo = function() {
			return "otto";
		};
		let bar, __ks_0;
		if(Type.isValue(__ks_0 = foo()) ? (bar = __ks_0, false) : true) {
			throw new Error();
		}
		console.log(foo, bar);
	}
};
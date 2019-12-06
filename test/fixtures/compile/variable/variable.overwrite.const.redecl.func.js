var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	const x = 42;
	function foo() {
		let x = null;
		let __ks_0;
		if(Type.isValue(__ks_0 = bar()) ? (x = __ks_0, true) : false) {
			console.log(x);
		}
	}
};
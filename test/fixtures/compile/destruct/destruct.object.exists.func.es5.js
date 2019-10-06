var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	function foo() {
		return (() => {
			const d = new Dictionary();
			d.bar = "hello";
			d.baz = 3;
			return d;
		})();
	}
	let bar = 0;
	let baz, __ks_0;
	bar = (__ks_0 = foo()).bar, baz = __ks_0.baz;
	console.log(bar);
	console.log(baz);
};
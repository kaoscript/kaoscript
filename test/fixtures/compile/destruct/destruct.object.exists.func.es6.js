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
	let baz;
	({bar, baz} = foo());
	console.log(bar);
	console.log(baz);
};
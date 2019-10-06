var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	const foo = (() => {
		const d = new Dictionary();
		d.bar = "hello";
		d.baz = 3;
		return d;
	})();
	let bar = "foo";
	let baz;
	({bar, baz} = foo);
	console.log(bar, baz);
};
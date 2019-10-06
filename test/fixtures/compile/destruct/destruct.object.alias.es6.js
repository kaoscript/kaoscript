var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	let foo = (() => {
		const d = new Dictionary();
		d.bar = "hello";
		d.baz = 3;
		return d;
	})();
	let {bar: a, baz: b} = foo;
	console.log(a);
	console.log(b);
};
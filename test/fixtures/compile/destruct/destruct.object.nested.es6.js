var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	let foo = (() => {
		const d = new Dictionary();
		d.bar = (() => {
			const d = new Dictionary();
			d.n1 = "hello";
			d.n2 = "world";
			return d;
		})();
		return d;
	})();
	let {bar: {n1, n2: qux}} = foo;
	console.log(n1, qux);
};
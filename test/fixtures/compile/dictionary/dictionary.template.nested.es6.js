var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	let x = "y";
	let foo = (() => {
		const d = new Dictionary();
		d.bar = (() => {
			const d = new Dictionary();
			d[x] = 42;
			return d;
		})();
		return d;
	})();
};
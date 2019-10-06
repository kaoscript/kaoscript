var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	let x = "y";
	let foo = (() => {
		const d = new Dictionary();
		d[x] = function() {
			return 42;
		};
		return d;
	})();
};
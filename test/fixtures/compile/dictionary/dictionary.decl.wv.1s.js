var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	let foo = (() => {
		const d = new Dictionary();
		d.bar = "hello";
		return d;
	})();
};
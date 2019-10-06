var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	let foo = (() => {
		const d = new Dictionary();
		d.bar = "qux";
		return d;
	})();
	delete foo.bar;
};
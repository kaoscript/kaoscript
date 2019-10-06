var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	var __ks_SyntaxError = {};
	const foobar = (() => {
		const d = new Dictionary();
		d.corge = function() {
			throw new SyntaxError();
		};
		return d;
	})();
};
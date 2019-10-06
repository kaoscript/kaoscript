var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	let x = 24;
	function foo() {
		return (() => {
			const d = new Dictionary();
			d[x] = 42;
			return d;
		})();
	}
};
var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	function foobar(x = (() => {
		const d = new Dictionary();
		d.y = 42;
		return d;
	})()) {
	}
};
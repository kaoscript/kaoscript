var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	function foobar() {
		return 42;
	}
	let x = null;
	let y = new Dictionary();
	x = y.x = foobar();
};
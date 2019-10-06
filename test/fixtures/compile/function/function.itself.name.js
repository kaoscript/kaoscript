var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	function foo() {
		const cache = foo.cache;
	}
	foo.cache = new Dictionary();
};
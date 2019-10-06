var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	function foobar(x) {
		if(x === void 0 || x === null) {
			x = (() => {
				const d = new Dictionary();
				d.y = 42;
				return d;
			})();
		}
	}
};
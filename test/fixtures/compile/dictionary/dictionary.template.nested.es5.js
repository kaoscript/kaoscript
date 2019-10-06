var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	var x = "y";
	var foo = (function() {
		var d = new Dictionary();
		d.bar = (function() {
			var d = new Dictionary();
			d[x] = 42;
			return d;
		})();
		return d;
	})();
};
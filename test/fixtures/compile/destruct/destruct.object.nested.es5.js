var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	var foo = (function() {
		var d = new Dictionary();
		d.bar = (function() {
			var d = new Dictionary();
			d.n1 = "hello";
			d.n2 = "world";
			return d;
		})();
		return d;
	})();
	var n1 = foo.bar.n1, qux = foo.bar.n2;
	console.log(n1, qux);
};
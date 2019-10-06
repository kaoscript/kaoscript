var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	var foo = (function() {
		var d = new Dictionary();
		d.bar = "hello";
		d.baz = 3;
		return d;
	})();
	var a = foo.bar, b = foo.baz;
	console.log(a);
	console.log(b);
};
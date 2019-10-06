var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	var foo = (() => {
		var d = new Dictionary();
		d.bar = "hello";
		d.baz = 3;
		return d;
	})();
	var bar = foo.bar, baz = foo.baz;
	console.log(bar, baz);
};
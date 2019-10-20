var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	function foobar({x, y} = (() => {
		const d = new Dictionary();
		d.x = "foo";
		d.y = "bar";
		return d;
	})()) {
		console.log(x + "." + y);
	}
};
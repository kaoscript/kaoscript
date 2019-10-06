var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	function foo() {
		return (() => {
			const d = new Dictionary();
			d.x = 1;
			d.y = 2;
			return d;
		})();
	}
	let {x, y} = foo();
	console.log(x, y);
};
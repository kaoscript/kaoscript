const {Dictionary} = require("@kaoscript/runtime");
module.exports = function() {
	let x = "y";
	let foo = (() => {
		const d = new Dictionary();
		d[x] = 42;
		return d;
	})();
};
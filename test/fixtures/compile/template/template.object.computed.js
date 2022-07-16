const {Dictionary} = require("@kaoscript/runtime");
module.exports = function() {
	let x = [24];
	let foo = (() => {
		const d = new Dictionary();
		d[x[0]] = 42;
		return d;
	})();
};
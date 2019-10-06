var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	let x = 2;
	let y = -1;
	let z = 1;
	const foo = (() => {
		const d = new Dictionary();
		d.x = x;
		d.y = y;
		d.z = z;
		return d;
	})();
};
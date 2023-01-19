const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let x = 2;
	let y = -1;
	let z = 1;
	const foo = (() => {
		const o = new OBJ();
		o.x = x;
		o.y = y;
		o.z = z;
		return o;
	})();
};
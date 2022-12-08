const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let x = "y";
	let foo = (() => {
		const d = new OBJ();
		d.x = -10;
		d[x] = 42;
		return d;
	})();
};
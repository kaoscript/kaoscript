const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let x = "y";
	let foo = (() => {
		const o = new OBJ();
		o.x = -10;
		o[x] = 42;
		return o;
	})();
};
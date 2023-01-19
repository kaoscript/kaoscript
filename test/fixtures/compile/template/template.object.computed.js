const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let x = [24];
	let foo = (() => {
		const o = new OBJ();
		o[x[0]] = 42;
		return o;
	})();
};
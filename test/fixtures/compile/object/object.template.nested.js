const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let x = "y";
	let foo = (() => {
		const o = new OBJ();
		o.bar = (() => {
			const o = new OBJ();
			o[x] = 42;
			return o;
		})();
		return o;
	})();
};
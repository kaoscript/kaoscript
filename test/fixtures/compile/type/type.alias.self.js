const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const f1 = new OBJ();
	const f2 = (() => {
		const o = new OBJ();
		o.parent = f1;
		return o;
	})();
};
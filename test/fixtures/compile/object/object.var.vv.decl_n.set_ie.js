const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const x = (() => {
		const o = new OBJ();
		o.y = null;
		return o;
	})();
	x.y = 42;
};
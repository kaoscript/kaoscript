const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const x = (() => {
		const d = new OBJ();
		d.y = null;
		return d;
	})();
	x.y = 42;
};
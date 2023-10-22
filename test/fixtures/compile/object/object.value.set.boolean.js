const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const x = (() => {
		const o = new OBJ();
		o.value = false;
		return o;
	})();
	x.value = true;
};
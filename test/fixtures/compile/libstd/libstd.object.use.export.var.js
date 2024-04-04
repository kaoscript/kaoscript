const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const foobar = (() => {
		const o = new OBJ();
		o.x = 0;
		o.y = 0;
		o.z = 0;
		return o;
	})();
	return {
		foobar
	};
};
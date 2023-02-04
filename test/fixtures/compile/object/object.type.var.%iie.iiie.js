const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let values = (() => {
		const o = new OBJ();
		o.x = 1;
		o.y = 2;
		return o;
	})();
	values = (() => {
		const o = new OBJ();
		o.x = 1;
		o.y = 2;
		o.z = 3;
		return o;
	})();
};
const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let d = 42;
	let foobar = (() => {
		const o = new OBJ();
		o.x = d;
		return o;
	})();
};
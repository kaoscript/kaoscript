const {OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foobar = Type.isValue(x.y) ? x.y : (() => {
		const o = new OBJ();
		o.x = 42;
		return o;
	})();
};
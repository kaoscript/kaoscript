const {OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foobar = Type.isValue(x.y) ? x.y : (() => {
		const d = new OBJ();
		d.x = 42;
		return d;
	})();
};
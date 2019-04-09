var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let Qux = {
		abc: 0,
		def: 1,
		ghi: 2
	};
	function foobar(x, y, filter) {
		if(arguments.length < 3) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		if(filter === void 0 || filter === null) {
			throw new TypeError("'filter' is not nullable");
		}
		const z = filter(x, y, Qux.abc);
		if(Type.isValue(z)) {
			return z;
		}
		return x + y;
	}
};
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isPrimitive(x)) {
			throw new TypeError("'x' is not of type 'Primitive'");
		}
	}
	foobar(42);
	foobar(true);
	foobar("quxbaz");
	return {
		foobar: foobar
	};
};
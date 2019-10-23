var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0) {
			x = null;
		}
		else if(x !== null && !(Type.isNumber(x) || Type.isString(x))) {
			throw new TypeError("'x' is not of type 'Number' or 'String'");
		}
	}
	foobar(42);
	foobar("White");
	foobar(null);
	return {
		foobar: foobar
	};
};
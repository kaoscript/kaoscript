var yourtype = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		if(yourtype.isString(x)) {
			return x.toInt();
		}
		else {
			return y;
		}
	}
}
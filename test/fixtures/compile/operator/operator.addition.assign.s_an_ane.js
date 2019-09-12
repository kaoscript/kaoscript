var {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar(x, y, z) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isString(x)) {
			throw new TypeError("'x' is not of type 'String'");
		}
		if(y === void 0) {
			y = null;
		}
		if(z === void 0) {
			z = null;
		}
		x = Helper.concatString(x, Operator.addOrConcat(y, z));
	}
};
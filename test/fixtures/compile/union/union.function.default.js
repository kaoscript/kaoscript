var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!(Type.isObject(x) || Type.isString(x))) {
			throw new TypeError("'x' is not of type 'Object' or 'String'");
		}
	}
	function bar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!(Type.isObject(x) || Type.isString(x))) {
			throw new TypeError("'x' is not of type 'Object' or 'String'");
		}
		foo(x);
	}
};
var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(Type.isString(x)) {
			console.log(x);
		}
		else {
			console.log(Helper.toString(x));
		}
	}
};
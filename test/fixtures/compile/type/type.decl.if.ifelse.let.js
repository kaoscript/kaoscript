var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isBoolean(x)) {
			throw new TypeError("'x' is not of type 'Boolean'");
		}
		let y = null;
		if(x) {
			let y = null;
			y = "42 * x";
		}
		else {
			let y = null;
			y = "24 * x";
		}
		return Helper.toString(y);
	}
};
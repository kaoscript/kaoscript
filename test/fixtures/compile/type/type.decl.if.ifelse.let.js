var Type = require("@kaoscript/runtime").Type;
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
		let y;
		if(x) {
			let y;
			y = "42 * x";
		}
		else {
			let y;
			y = "24 * x";
		}
		return "" + y;
	}
};
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	const foo = function(a, b) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(a === void 0 || a === null) {
			throw new TypeError("'a' is not nullable");
		}
		else if(!Type.isNumber(a)) {
			throw new TypeError("'a' is not of type 'Number'");
		}
		if(b === void 0 || b === null) {
			throw new TypeError("'b' is not nullable");
		}
		else if(!Type.isNumber(b)) {
			throw new TypeError("'b' is not of type 'Number'");
		}
		return a - b;
	};
};
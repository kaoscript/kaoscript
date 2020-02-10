var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(i, b) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(i === void 0 || i === null) {
			throw new TypeError("'i' is not nullable");
		}
		else if(!Type.isNumber(i)) {
			throw new TypeError("'i' is not of type 'Number'");
		}
		if(b === void 0 || b === null) {
			throw new TypeError("'b' is not nullable");
		}
		let x = i;
		if(b === 0) {
			x = null;
		}
		else {
		}
		if(x === null) {
		}
	}
};
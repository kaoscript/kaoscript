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
		else if(!Type.isBoolean(b)) {
			throw new TypeError("'b' is not of type 'Boolean'");
		}
		let x = i;
		for(let j = 0; j <= 1; ++j) {
			x = null;
		}
		if(x === null) {
		}
	}
};
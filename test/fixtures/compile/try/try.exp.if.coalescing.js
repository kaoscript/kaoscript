var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	function test(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(x === true) {
			return true;
		}
		else {
			throw new Error("foobar");
		}
	}
	if(Helper.try(() => test(true), false)) {
	}
	else {
	}
};
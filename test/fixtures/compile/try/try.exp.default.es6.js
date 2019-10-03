var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(x === true) {
			return 42;
		}
		else {
			throw new Error("foobar");
		}
	}
	Helper.try(() => foobar(true), null);
};
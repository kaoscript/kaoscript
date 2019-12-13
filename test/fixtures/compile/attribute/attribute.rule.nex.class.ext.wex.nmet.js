var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isClassInstance(x, Foobar)) {
			throw new TypeError("'x' is not of type 'Foobar'");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		else if(!Type.isClassInstance(y, Foobar)) {
			throw new TypeError("'y' is not of type 'Foobar'");
		}
		if(x.foobar() === y.foobar()) {
		}
	}
};
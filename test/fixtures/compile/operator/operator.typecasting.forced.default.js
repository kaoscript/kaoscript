var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		return 42;
	}
	function quxbaz(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isNumber(x)) {
			throw new TypeError("'x' is not of type 'Number'");
		}
	}
	quxbaz(foobar());
	quxbaz(foobar());
};
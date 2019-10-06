var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	function foobar(a, b, c) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(a === void 0 || a === null) {
			throw new TypeError("'a' is not nullable");
		}
		if(b === void 0 || b === null) {
			throw new TypeError("'b' is not nullable");
		}
		if(c === void 0 || c === null) {
			throw new TypeError("'c' is not nullable");
		}
		let x;
		if(a === true) {
			x = (() => {
				const d = new Dictionary();
				d.b = b;
				d.c = c;
				return d;
			})();
		}
	}
};
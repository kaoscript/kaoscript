module.exports = function() {
	function foobar(a, b, c, d, e) {
		if(arguments.length < 5) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 5)");
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
		if(d === void 0 || d === null) {
			throw new TypeError("'d' is not nullable");
		}
		if(e === void 0 || e === null) {
			throw new TypeError("'e' is not nullable");
		}
		if(a === b && b === c && c === d && d === e) {
		}
	}
};
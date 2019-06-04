module.exports = function() {
	function foobar(a, b, c, d, e, f, g, h, i, j) {
		if(arguments.length < 10) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 10)");
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
		if(f === void 0 || f === null) {
			throw new TypeError("'f' is not nullable");
		}
		if(g === void 0 || g === null) {
			throw new TypeError("'g' is not nullable");
		}
		if(h === void 0 || h === null) {
			throw new TypeError("'h' is not nullable");
		}
		if(i === void 0 || i === null) {
			throw new TypeError("'i' is not nullable");
		}
		if(j === void 0 || j === null) {
			throw new TypeError("'j' is not nullable");
		}
		if(a < b && b <= c && c < d && d === e && e > f && f >= g && g === h && h < i && i !== j) {
		}
	}
	foobar(1, 2, 2, 3, 3, 2, 1, 1, 3, 5);
};
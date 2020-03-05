var Operator = require("@kaoscript/runtime").Operator;
module.exports = function() {
	function foobar(a, b, c, d, e, f, g, h, i, j) {
		if(arguments.length < 10) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 10)");
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
		let __ks_0;
		if(Operator.lt(a(), __ks_0 = b()) && Operator.lte(__ks_0, __ks_0 = c()) && Operator.lt(__ks_0, __ks_0 = d()) && __ks_0 === (__ks_0 = e()) && Operator.gt(__ks_0, __ks_0 = f()) && Operator.gte(__ks_0, __ks_0 = g()) && __ks_0 === (__ks_0 = h()) && Operator.lt(__ks_0, __ks_0 = i()) && __ks_0 !== j()) {
		}
	}
	foobar(() => {
		return 1;
	}, () => {
		return 2;
	}, () => {
		return 2;
	}, () => {
		return 3;
	}, () => {
		return 3;
	}, () => {
		return 2;
	}, () => {
		return 1;
	}, () => {
		return 1;
	}, () => {
		return 3;
	}, () => {
		return 5;
	});
};
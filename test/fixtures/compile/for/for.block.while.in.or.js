module.exports = function() {
	function foobar(values, x, y) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(values === void 0 || values === null) {
			throw new TypeError("'values' is not nullable");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		for(let __ks_0 = 0, __ks_1 = values.length, value; __ks_0 < __ks_1 && ((x === true) || (y === true)); ++__ks_0) {
			value = values[__ks_0];
		}
	}
};
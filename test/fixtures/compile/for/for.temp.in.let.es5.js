module.exports = function() {
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		for(var __ks_0 = 0, __ks_1 = x.values(), __ks_2 = __ks_1.length, __ks_x_1; __ks_0 < __ks_2; ++__ks_0) {
			__ks_x_1 = __ks_1[__ks_0];
		}
	}
};
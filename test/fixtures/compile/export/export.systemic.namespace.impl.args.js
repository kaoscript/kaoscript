module.exports = function() {
	var __ks_Math = {};
	__ks_Math.foo = function(x, y, z) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(y === void 0) {
			y = null;
		}
		if(z === void 0 || z === null) {
			z = -1;
		}
		return "" + x + "." + y + "." + z;
	};
	return {
		__ks_Math: __ks_Math
	};
};
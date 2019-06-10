module.exports = function() {
	function foobar(values) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(values === void 0 || values === null) {
			throw new TypeError("'values' is not nullable");
		}
		var line;
		var __ks_2;
		for(var __ks_0 = 0, __ks_1 = values.length, element; __ks_0 < __ks_1; ++__ks_0) {
			line = (__ks_2 = values[__ks_0]).line, element = __ks_2.element;
		}
	}
};
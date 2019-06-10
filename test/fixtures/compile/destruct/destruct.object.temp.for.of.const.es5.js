module.exports = function() {
	function foobar(values) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(values === void 0 || values === null) {
			throw new TypeError("'values' is not nullable");
		}
		var __ks_1;
		for(var __ks_0 in values) {
			var line = (__ks_1 = values[__ks_0]).line, element = __ks_1.element;
		}
	}
};
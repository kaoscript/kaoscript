module.exports = function() {
	function foobar(values) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(values === void 0 || values === null) {
			throw new TypeError("'values' is not nullable");
		}
		let line;
		for(let __ks_0 = 0, __ks_1 = values.length, element; __ks_0 < __ks_1; ++__ks_0) {
			{line, element} = values[__ks_0];
		}
	}
};
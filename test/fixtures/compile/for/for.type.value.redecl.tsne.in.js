module.exports = function() {
	function foobar(values) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(values === void 0 || values === null) {
			throw new TypeError("'values' is not nullable");
		}
		let value = null;
		for(let __ks_0 = 0, __ks_1 = values.length; __ks_0 < __ks_1; ++__ks_0) {
			value = values[__ks_0];
			console.log(value);
		}
	}
};
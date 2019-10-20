module.exports = function() {
	function foobar(values) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(values === void 0 || values === null) {
			throw new TypeError("'values' is not nullable");
		}
		let value;
		for(let __ks_0 in values) {
			value = values[__ks_0];
			console.log(value);
		}
	}
};
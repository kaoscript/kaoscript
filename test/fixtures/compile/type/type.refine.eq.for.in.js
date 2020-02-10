var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(i, values) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(i === void 0 || i === null) {
			throw new TypeError("'i' is not nullable");
		}
		else if(!Type.isNumber(i)) {
			throw new TypeError("'i' is not of type 'Number'");
		}
		if(values === void 0 || values === null) {
			throw new TypeError("'values' is not nullable");
		}
		let x = i;
		for(let __ks_0 = 0, __ks_1 = values.length, value; __ks_0 < __ks_1; ++__ks_0) {
			value = values[__ks_0];
			x = null;
		}
		if(x === null) {
		}
	}
};
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(values) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(values === void 0 || values === null) {
			throw new TypeError("'values' is not nullable");
		}
		else if(!Type.isArray(values)) {
			throw new TypeError("'values' is not of type 'Array'");
		}
		for(let __ks_0 = 0, __ks_1 = values.length, value; __ks_0 < __ks_1; ++__ks_0) {
			value = values[__ks_0];
			if(Type.isString(value)) {
				console.log(value);
			}
		}
	}
};
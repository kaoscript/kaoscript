var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar(values) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(values === void 0 || values === null) {
			throw new TypeError("'values' is not nullable");
		}
		else if(!Type.isArray(values)) {
			throw new TypeError("'values' is not of type 'Array'");
		}
		for(let __ks_0 = 0, __ks_1 = Helper.mapObject(values, function(__ks_0, value) {
			return value.values();
		}), __ks_2 = __ks_1.length, __ks_values_1; __ks_0 < __ks_2; ++__ks_0) {
			__ks_values_1 = __ks_1[__ks_0];
		}
	}
};
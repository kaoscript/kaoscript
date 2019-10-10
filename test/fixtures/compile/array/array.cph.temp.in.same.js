var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	function foobar(values) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(values === void 0 || values === null) {
			throw new TypeError("'values' is not nullable");
		}
		const __ks_value_1 = Helper.mapArray(values, function(value) {
			return value;
		});
		return __ks_value_1;
	}
};
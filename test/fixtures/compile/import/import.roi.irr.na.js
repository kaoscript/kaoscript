require("kaoscript/register");
var {Helper, Operator} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = require("./import.roi.rr.ks")().__ks_Array;
	const m = __ks_Array._cm_map(Helper.newArrayRange(1, 10, 1, true, true), function(value, index) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		if(index === void 0 || index === null) {
			throw new TypeError("'index' is not nullable");
		}
		return Operator.multiplication(value, index);
	});
	return {
		__ks_Array: __ks_Array
	};
};
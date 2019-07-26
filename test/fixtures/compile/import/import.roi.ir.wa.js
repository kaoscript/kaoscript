require("kaoscript/register");
var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var {Array, __ks_Array} = require("../_/_array.ks")();
	var {Array, __ks_Array} = require("../require/require.alt.roi.default.ks")(Array, __ks_Array);
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
		return value * index;
	});
	return {
		Array: Array,
		__ks_Array: __ks_Array
	};
};
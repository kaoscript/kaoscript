require("kaoscript/register");
module.exports = function() {
	var {Array, __ks_Array} = require("./import.roe.rr.ks")();
	return {
		Array: Array,
		__ks_Array: __ks_Array
	};
};
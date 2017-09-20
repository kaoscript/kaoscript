require("kaoscript/register");
module.exports = function() {
	var __ks_Array = {};
	var {Array, __ks_Array} = require("./_array.map.ks")(Array, __ks_Array);
	var {Array, __ks_Array} = require("./_array.last.ks")(Array, __ks_Array);
	return {
		Array: Array,
		__ks_Array: __ks_Array
	};
};
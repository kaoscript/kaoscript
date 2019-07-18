require("kaoscript/register");
module.exports = function() {
	var __ks_Array = {};
	__ks_Array.__ks_func_foobar_0 = function() {
		return 42;
	};
	__ks_Array._im_foobar = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Array.__ks_func_foobar_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	var {Array, __ks_Array} = require("../require/require.alt.roe.default.ks")(Array, __ks_Array);
	return {
		Array: Array,
		__ks_Array: __ks_Array
	};
};
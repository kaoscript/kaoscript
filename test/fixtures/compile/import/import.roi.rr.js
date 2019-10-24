require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function(Array, __ks_Array) {
	if(!Type.isValue(Array)) {
		var {Array, __ks_Array} = require("../require/require.alt.roi.default.es6.ks")();
	}
	__ks_Array.__ks_func_foo_0 = function() {
		return 42;
	};
	__ks_Array._im_foo = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Array.__ks_func_foo_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		Array: Array,
		__ks_Array: __ks_Array
	};
};
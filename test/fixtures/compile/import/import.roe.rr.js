require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function(__ks_Array) {
	if(!Type.isValue(__ks_Array)) {
		var __ks_Array = require("../require/require.alt.roe.array.ks")().__ks_Array;
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
		__ks_Array: __ks_Array
	};
};
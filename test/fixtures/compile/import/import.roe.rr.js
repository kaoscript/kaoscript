require("kaoscript/register");
function __ks_require(__ks_0, __ks___ks_0) {
	if(Type.isValue(__ks_0)) {
		return [__ks_0, __ks___ks_0];
	}
	else {
		var {Array, __ks_Array} = require("../require/require.alt.roe.default.ks")();
		return [Array, __ks_Array];
	}
}
module.exports = function(__ks_0, __ks___ks_0) {
	var [Array, __ks_Array] = __ks_require(__ks_0, __ks___ks_0);
	__ks_Array.__ks_func_foo_0 = function() {
		return 42;
	};
	__ks_Array._im_foo = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Array.__ks_func_foo_0.apply(that);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	return {
		Array: Array,
		__ks_Array: __ks_Array
	};
};
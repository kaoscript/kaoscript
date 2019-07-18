require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
function __ks_require(__ks_0, __ks___ks_0) {
	var req = [];
	if(Type.isValue(__ks_0)) {
		req.push(__ks_0, __ks___ks_0);
	}
	else {
		var {Array, __ks_Array} = require("../require/require.alt.roe.default.ks")();
		req.push(Array, __ks_Array);
	}
	return req;
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
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		Array: Array,
		__ks_Array: __ks_Array
	};
};
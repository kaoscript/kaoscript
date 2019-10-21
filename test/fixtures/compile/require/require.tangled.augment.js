require("kaoscript/register");
module.exports = function() {
	var {Foobar, __ks_Foobar, Error, __ks_Error, FooError} = require("./require.tangled.genesis.ks")();
	__ks_Foobar.__ks_func_foobar_0 = function() {
	};
	__ks_Foobar._im_foobar = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Foobar.__ks_func_foobar_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		Foobar: Foobar,
		__ks_Foobar: __ks_Foobar
	};
};
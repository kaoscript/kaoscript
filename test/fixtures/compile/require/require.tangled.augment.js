require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var {Foobar, __ks_Foobar, __ks_Error, FooError} = require("./.require.tangled.genesis.ks.1b7cst1.ksb")();
	__ks_Foobar.__ks_func_foobar_0 = function() {
	};
	__ks_Foobar._im_foobar = function(that, ...args) {
		return __ks_Foobar.__ks_func_foobar_rt(that, args);
	};
	__ks_Foobar.__ks_func_foobar_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Foobar.__ks_func_foobar_0.call(that);
		}
		if(that.foobar) {
			return that.foobar(...args);
		}
		throw Helper.badArgs();
	};
	return {
		Foobar,
		__ks_Foobar
	};
};
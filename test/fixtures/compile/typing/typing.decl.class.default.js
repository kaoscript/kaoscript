const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Foobar = {};
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
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x) {
		let y = null;
		y = bar.__ks_0();
		if(y !== null) {
			__ks_Foobar.__ks_func_foobar_0.call(y);
		}
	};
	foo.__ks_rt = function(that, args) {
		const t0 = Type.isBoolean;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foo.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function bar() {
		return bar.__ks_rt(this, arguments);
	};
	bar.__ks_0 = function() {
	};
	bar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return bar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};
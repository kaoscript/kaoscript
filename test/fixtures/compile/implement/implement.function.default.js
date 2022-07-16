const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Function = {};
	__ks_Function.__ks_func_foo_0 = function() {
		return Helper.concatString("foo", this());
	};
	__ks_Function._im_foo = function(that, ...args) {
		return __ks_Function.__ks_func_foo_rt(that, args);
	};
	__ks_Function.__ks_func_foo_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Function.__ks_func_foo_0.call(that);
		}
		if(that.foo) {
			return that.foo(...args);
		}
		throw Helper.badArgs();
	};
	function bar() {
		return bar.__ks_rt(this, arguments);
	};
	bar.__ks_0 = function() {
		return "bar";
	};
	bar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return bar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	console.log(__ks_Function.__ks_func_foo_0.call(bar));
};
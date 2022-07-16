const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_SyntaxError = {};
	__ks_SyntaxError.__ks_func_foo_0 = function() {
		return "bar";
	};
	__ks_SyntaxError._im_foo = function(that, ...args) {
		return __ks_SyntaxError.__ks_func_foo_rt(that, args);
	};
	__ks_SyntaxError.__ks_func_foo_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_SyntaxError.__ks_func_foo_0.call(that);
		}
		if(that.foo) {
			return that.foo(...args);
		}
		throw Helper.badArgs();
	};
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function() {
	};
	foo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	return {
		foo,
		__ks_SyntaxError
	};
};
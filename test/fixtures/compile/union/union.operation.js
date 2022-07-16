require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Number = require("../_/._number.ks.j5k8r9.ksb")().__ks_Number;
	var __ks_String = require("../_/._string.ks.j5k8r9.ksb")().__ks_String;
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x) {
		return 42 - (Type.isString(x) ? __ks_String.__ks_func_toFloat_0.call(x) : __ks_Number.__ks_func_toFloat_0.call(x));
	};
	foo.__ks_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isString(value);
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
	bar.__ks_0 = function(x, y) {
		return (Type.isString(x) ? __ks_String.__ks_func_toFloat_0.call(x) : __ks_Number.__ks_func_toFloat_0.call(x)) - (Type.isString(y) ? __ks_String.__ks_func_toFloat_0.call(y) : __ks_Number.__ks_func_toFloat_0.call(y));
	};
	bar.__ks_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isString(value);
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return bar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};
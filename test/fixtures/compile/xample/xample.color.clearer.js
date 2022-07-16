require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Number = require("../_/._number.ks.j5k8r9.ksb")().__ks_Number;
	var __ks_String = require("../_/._string.ks.j5k8r9.ksb")().__ks_String;
	__ks_String.__ks_func_endsWith_0 = function(value) {
		return (this.length >= value.length) && (this.slice(this.length - value.length) === value);
	};
	__ks_String._im_endsWith = function(that, ...args) {
		return __ks_String.__ks_func_endsWith_rt(that, args);
	};
	__ks_String.__ks_func_endsWith_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_String.__ks_func_endsWith_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function clearer() {
		return clearer.__ks_rt(this, arguments);
	};
	clearer.__ks_0 = function(current, value) {
		if(Type.isString(value) && __ks_String.__ks_func_endsWith_0.call(value, "%")) {
			return current * ((100 - __ks_String.__ks_func_toFloat_0.call(value)) / 100);
		}
		else {
			return current - (Type.isString(value) ? __ks_String.__ks_func_toFloat_0.call(value) : __ks_Number.__ks_func_toFloat_0.call(value));
		}
	};
	clearer.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = value => Type.isNumber(value) || Type.isString(value);
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return clearer.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};
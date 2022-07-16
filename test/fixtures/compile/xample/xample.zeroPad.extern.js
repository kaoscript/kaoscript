const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Number = {};
	__ks_Number.__ks_func_zeroPad_0 = function(length) {
		return __ks_String._im_lpad(this.toString(), length, "0");
	};
	__ks_Number._im_zeroPad = function(that, ...args) {
		return __ks_Number.__ks_func_zeroPad_rt(that, args);
	};
	__ks_Number.__ks_func_zeroPad_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_Number.__ks_func_zeroPad_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	var __ks_String = {};
	__ks_String.__ks_func_lpad_0 = function(length, pad) {
		return pad.repeat(length - this.length) + this;
	};
	__ks_String._im_lpad = function(that, ...args) {
		return __ks_String.__ks_func_lpad_rt(that, args);
	};
	__ks_String.__ks_func_lpad_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = Type.isString;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return __ks_String.__ks_func_lpad_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};
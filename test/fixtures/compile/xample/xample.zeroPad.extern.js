var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Number = {};
	__ks_Number.__ks_func_zeroPad_0 = function(length) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(length === void 0 || length === null) {
			throw new TypeError("'length' is not nullable");
		}
		return __ks_String._im_lpad(this.toString(), length, "0");
	};
	__ks_Number._im_zeroPad = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 1) {
			return __ks_Number.__ks_func_zeroPad_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	var __ks_String = {};
	__ks_String.__ks_func_lpad_0 = function(length, pad) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(length === void 0 || length === null) {
			throw new TypeError("'length' is not nullable");
		}
		else if(!Type.isNumber(length)) {
			throw new TypeError("'length' is not of type 'Number'");
		}
		if(pad === void 0 || pad === null) {
			throw new TypeError("'pad' is not nullable");
		}
		else if(!Type.isString(pad)) {
			throw new TypeError("'pad' is not of type 'String'");
		}
		return pad.repeat(length - this.length) + this;
	};
	__ks_String._im_lpad = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 2) {
			return __ks_String.__ks_func_lpad_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
};
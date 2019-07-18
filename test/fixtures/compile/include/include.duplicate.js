var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_String = {};
	__ks_String.__ks_func_lines_0 = function(emptyLines) {
		if(emptyLines === void 0 || emptyLines === null) {
			emptyLines = false;
		}
		if(this.length === 0) {
			return [];
		}
		else if(emptyLines) {
			return this.replace(/\r\n/g, "\n").replace(/\r/g, "\n").split("\n");
		}
		else {
			let __ks_0;
			return Type.isValue(__ks_0 = this.match(/[^\r\n]+/g)) ? __ks_0 : [];
		}
	};
	__ks_String.__ks_func_lower_0 = function() {
		return this.toLowerCase();
	};
	__ks_String.__ks_func_toFloat_0 = function() {
		return parseFloat(this);
	};
	__ks_String.__ks_func_toInt_0 = function(base) {
		if(base === void 0 || base === null) {
			base = 10;
		}
		return parseInt(this, base);
	};
	__ks_String._im_lines = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length >= 0 && args.length <= 1) {
			return __ks_String.__ks_func_lines_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_String._im_lower = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_String.__ks_func_lower_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_String._im_toFloat = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_String.__ks_func_toFloat_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_String._im_toInt = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length >= 0 && args.length <= 1) {
			return __ks_String.__ks_func_toInt_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		String: String,
		__ks_String: __ks_String
	};
};
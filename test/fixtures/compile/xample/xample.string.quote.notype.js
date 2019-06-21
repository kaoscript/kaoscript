var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_String = {};
	__ks_String.__ks_func_quote_0 = function() {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		let __ks_i = -1;
		let quote;
		if(arguments.length > 1 && (quote = arguments[++__ks_i]) !== void 0 && quote !== null) {
			if(!Type.isString(quote)) {
				throw new TypeError("'quote' is not of type 'String'");
			}
		}
		else {
			quote = "\"";
		}
		let escape = arguments[++__ks_i];
		if(escape === void 0 || escape === null) {
			throw new TypeError("'escape' is not nullable");
		}
		else if(!Type.isString(escape)) {
			throw new TypeError("'escape' is not of type 'String'");
		}
		return quote + __ks_String._im_replaceAll(__ks_String._im_replaceAll(this, escape, escape + escape), quote, escape + quote) + quote;
	};
	__ks_String.__ks_func_replaceAll_0 = function(find, replacement) {
		if(arguments.length < 2) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(find === void 0 || find === null) {
			throw new TypeError("'find' is not nullable");
		}
		else if(!Type.isString(find)) {
			throw new TypeError("'find' is not of type 'String'");
		}
		if(replacement === void 0 || replacement === null) {
			throw new TypeError("'replacement' is not nullable");
		}
		else if(!Type.isString(replacement)) {
			throw new TypeError("'replacement' is not of type 'String'");
		}
		return this;
	};
	__ks_String._im_quote = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length >= 1 && args.length <= 2) {
			return __ks_String.__ks_func_quote_0.apply(that, args);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	__ks_String._im_replaceAll = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 2) {
			return __ks_String.__ks_func_replaceAll_0.apply(that, args);
		}
		throw new SyntaxError("wrong number of arguments");
	};
};
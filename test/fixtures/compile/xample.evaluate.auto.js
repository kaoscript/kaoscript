var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_String = {};
	__ks_String.__ks_func_evaluate_0 = function() {
		let value = this.trim();
		if(__ks_String._im_startsWith(value, "function") || __ks_String._im_startsWith(value, "{")) {
			return eval("(function(){return " + value + ";})()");
		}
		else {
			return eval(value);
		}
	};
	__ks_String._im_evaluate = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_String.__ks_func_evaluate_0.apply(that);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	__ks_String.__ks_func_startsWith_0 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		else if(!Type.isString(value)) {
			throw new TypeError("'value' is not of type 'String'");
		}
		return (this.length >= value.length) && (this.slice(0, value.length) === value);
	};
	__ks_String._im_startsWith = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 1) {
			return __ks_String.__ks_func_startsWith_0.apply(that, args);
		}
		throw new SyntaxError("wrong number of arguments");
	};
}
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_String = {};
	__ks_String.__ks_func_endsWith_0 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		else if(!Type.isString(value)) {
			throw new TypeError("'value' is not of type 'String'");
		}
		return (this.length >= value.length) && (this.slice(this.length - value.length) === value);
	};
	__ks_String._im_endsWith = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 1) {
			return __ks_String.__ks_func_endsWith_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		String: String,
		__ks_String: __ks_String
	};
};
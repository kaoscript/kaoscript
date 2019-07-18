require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var {String, __ks_String} = require("../_/_string.ks")();
	__ks_String.__ks_func_endsWith_0 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
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
	function clearer(current, value) {
		if(arguments.length < 2) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(current === void 0 || current === null) {
			throw new TypeError("'current' is not nullable");
		}
		else if(!Type.isNumber(current)) {
			throw new TypeError("'current' is not of type 'Number'");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		else if(!(Type.isString(value) || Type.isNumber(value))) {
			throw new TypeError("'value' is not of type 'String' or 'Number'");
		}
		if(Type.isString(value) && __ks_String._im_endsWith(value, "%")) {
			return current * ((100 - __ks_String._im_toFloat(value)) / 100);
		}
		else {
			return current - (Type.isString(value) ? __ks_String._im_toFloat(value) : value.toFloat());
		}
	}
};
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		if(arguments.length >= 1 && Type.isArray(arguments[arguments.length - 1])) {
			let __ks_i = -1;
			let args = Array.prototype.slice.call(arguments, ++__ks_i, __ks_i = arguments.length - 1);
			let value = arguments[__ks_i];
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			else if(!Type.isArray(value)) {
				throw new TypeError("'value' is not of type 'Array'");
			}
			return "Array";
		}
		else if(arguments.length >= 1 && Type.isString(arguments[arguments.length - 1])) {
			let __ks_i = -1;
			let args = Array.prototype.slice.call(arguments, ++__ks_i, __ks_i = arguments.length - 1);
			let value = arguments[__ks_i];
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			else if(!Type.isString(value)) {
				throw new TypeError("'value' is not of type 'String'");
			}
			return "String";
		}
		else if(arguments.length >= 1) {
			let __ks_i = -1;
			let args = Array.prototype.slice.call(arguments, ++__ks_i, __ks_i = arguments.length - 1);
			let value = arguments[__ks_i];
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			return "Any";
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
	return {
		foobar: foobar
	};
};
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		if(arguments.length >= 1 && Type.isArray(arguments[0])) {
			let __ks_i = -1;
			let value = arguments[++__ks_i];
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			else if(!Type.isArray(value)) {
				throw new TypeError("'value' is not of type 'Array'");
			}
			let args = Array.prototype.slice.call(arguments, ++__ks_i, arguments.length);
			return "Array";
		}
		else if(arguments.length >= 1 && Type.isString(arguments[0])) {
			let __ks_i = -1;
			let value = arguments[++__ks_i];
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			else if(!Type.isString(value)) {
				throw new TypeError("'value' is not of type 'String'");
			}
			let args = Array.prototype.slice.call(arguments, ++__ks_i, arguments.length);
			return "String";
		}
		else if(arguments.length >= 1) {
			let __ks_i = -1;
			let value = arguments[++__ks_i];
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			let args = Array.prototype.slice.call(arguments, ++__ks_i, arguments.length);
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
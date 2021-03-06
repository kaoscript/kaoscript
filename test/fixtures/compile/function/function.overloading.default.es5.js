var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function reverse() {
		if(arguments.length === 1 && Type.isArray(arguments[0])) {
			var __ks_i = -1;
			var value = arguments[++__ks_i];
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			else if(!Type.isArray(value)) {
				throw new TypeError("'value' is not of type 'Array'");
			}
			return value.slice().reverse();
		}
		else if(arguments.length === 1) {
			var __ks_i = -1;
			var value = arguments[++__ks_i];
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			else if(!Type.isString(value)) {
				throw new TypeError("'value' is not of type 'String'");
			}
			return value.split("").reverse().join("");
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};
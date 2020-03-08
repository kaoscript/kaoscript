var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		if(arguments.length >= 1 && arguments.length <= 3 && Type.isString(arguments[0])) {
			let __ks_i = -1;
			let pattern = arguments[++__ks_i];
			if(pattern === void 0 || pattern === null) {
				throw new TypeError("'pattern' is not nullable");
			}
			else if(!Type.isString(pattern)) {
				throw new TypeError("'pattern' is not of type 'String'");
			}
			let position;
			if(arguments.length > ++__ks_i && (position = arguments[__ks_i]) !== void 0 && position !== null) {
				if(!Type.isBoolean(position) && !Type.isNumber(position)) {
					if(arguments.length - __ks_i < 2) {
						position = 0;
						--__ks_i;
					}
					else {
						throw new TypeError("'position' is not of type 'Boolean' or 'Number'");
					}
				}
			}
			else {
				position = 0;
			}
			let __ks_default_1;
			if(arguments.length > ++__ks_i && (__ks_default_1 = arguments[__ks_i]) !== void 0 && __ks_default_1 !== null) {
				if(!Type.isString(__ks_default_1)) {
					throw new TypeError("'default' is not of type 'String'");
				}
			}
			else {
				__ks_default_1 = "";
			}
			return 1;
		}
		else if(arguments.length >= 1 && arguments.length <= 3) {
			let __ks_i = -1;
			let pattern = arguments[++__ks_i];
			if(pattern === void 0 || pattern === null) {
				throw new TypeError("'pattern' is not nullable");
			}
			else if(!Type.isRegExp(pattern)) {
				throw new TypeError("'pattern' is not of type 'RegExp'");
			}
			let position;
			if(arguments.length > ++__ks_i && (position = arguments[__ks_i]) !== void 0 && position !== null) {
				if(!Type.isBoolean(position) && !Type.isNumber(position)) {
					if(arguments.length - __ks_i < 2) {
						position = 0;
						--__ks_i;
					}
					else {
						throw new TypeError("'position' is not of type 'Boolean' or 'Number'");
					}
				}
			}
			else {
				position = 0;
			}
			let __ks_default_1;
			if(arguments.length > ++__ks_i && (__ks_default_1 = arguments[__ks_i]) !== void 0 && __ks_default_1 !== null) {
				if(!Type.isString(__ks_default_1)) {
					throw new TypeError("'default' is not of type 'String'");
				}
			}
			else {
				__ks_default_1 = "";
			}
			return 2;
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};
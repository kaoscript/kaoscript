var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		if(arguments.length >= 1 && arguments.length <= 3 && Type.isString(arguments[0])) {
			let __ks_i = -1;
			let a = arguments[++__ks_i];
			if(a === void 0 || a === null) {
				throw new TypeError("'a' is not nullable");
			}
			else if(!Type.isString(a)) {
				throw new TypeError("'a' is not of type 'String'");
			}
			let b;
			if(arguments.length > ++__ks_i && (b = arguments[__ks_i]) !== void 0 && b !== null) {
				if(!(Type.isBoolean(b) || Type.isNumber(b))) {
					if(arguments.length - __ks_i < 2) {
						b = 0;
						--__ks_i;
					}
					else {
						throw new TypeError("'b' is not of type 'Boolean' or 'Number'");
					}
				}
			}
			else {
				b = 0;
			}
			let c;
			if(arguments.length > ++__ks_i && (c = arguments[__ks_i]) !== void 0 && c !== null) {
				if(!Type.isString(c)) {
					throw new TypeError("'c' is not of type 'String'");
				}
			}
			else {
				c = "";
			}
		}
		else if(arguments.length >= 1 && arguments.length <= 3) {
			let __ks_i = -1;
			let a = arguments[++__ks_i];
			if(a === void 0 || a === null) {
				throw new TypeError("'a' is not nullable");
			}
			else if(!Type.isRegExp(a)) {
				throw new TypeError("'a' is not of type 'RegExp'");
			}
			let b;
			if(arguments.length > ++__ks_i && (b = arguments[__ks_i]) !== void 0 && b !== null) {
				if(!(Type.isBoolean(b) || Type.isNumber(b))) {
					if(arguments.length - __ks_i < 2) {
						b = 0;
						--__ks_i;
					}
					else {
						throw new TypeError("'b' is not of type 'Boolean' or 'Number'");
					}
				}
			}
			else {
				b = 0;
			}
			let c;
			if(arguments.length > ++__ks_i && (c = arguments[__ks_i]) !== void 0 && c !== null) {
				if(!Type.isString(c)) {
					throw new TypeError("'c' is not of type 'String'");
				}
			}
			else {
				c = "";
			}
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
	foobar(/\s+/, "hello");
};
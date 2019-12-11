var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		if(arguments.length === 2) {
			let __ks_i = -1;
			let a = arguments[++__ks_i];
			if(a === void 0 || a === null) {
				throw new TypeError("'a' is not nullable");
			}
			else if(!Type.isString(a)) {
				throw new TypeError("'a' is not of type 'String'");
			}
			let b = arguments[++__ks_i];
			if(b === void 0 || b === null) {
				throw new TypeError("'b' is not nullable");
			}
			else if(!Type.isString(b)) {
				throw new TypeError("'b' is not of type 'String'");
			}
			return a;
		}
		else if(arguments.length === 3 || arguments.length === 4) {
			let __ks_i = -1;
			let a = arguments[++__ks_i];
			if(a === void 0 || a === null) {
				throw new TypeError("'a' is not nullable");
			}
			else if(!Type.isString(a)) {
				throw new TypeError("'a' is not of type 'String'");
			}
			let b = arguments[++__ks_i];
			if(b === void 0 || b === null) {
				throw new TypeError("'b' is not nullable");
			}
			else if(!Type.isNumber(b)) {
				throw new TypeError("'b' is not of type 'Number'");
			}
			let c;
			if(arguments.length > 3 && (c = arguments[++__ks_i]) !== void 0 && c !== null) {
				if(!Type.isBoolean(c)) {
					throw new TypeError("'c' is not of type 'Boolean'");
				}
			}
			else {
				c = false;
			}
			let d = arguments[++__ks_i];
			if(d === void 0 || d === null) {
				throw new TypeError("'d' is not nullable");
			}
			else if(!Type.isArray(d)) {
				throw new TypeError("'d' is not of type 'Array'");
			}
			return b;
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
	function quxbaz(a, b, c, d) {
		if(arguments.length < 4) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 4)");
		}
		if(a === void 0 || a === null) {
			throw new TypeError("'a' is not nullable");
		}
		else if(!Type.isString(a)) {
			throw new TypeError("'a' is not of type 'String'");
		}
		if(b === void 0 || b === null) {
			throw new TypeError("'b' is not nullable");
		}
		else if(!Type.isNumber(b)) {
			throw new TypeError("'b' is not of type 'Number'");
		}
		if(c === void 0 || c === null) {
			throw new TypeError("'c' is not nullable");
		}
		else if(!Type.isBoolean(c)) {
			throw new TypeError("'c' is not of type 'Boolean'");
		}
		if(d === void 0 || d === null) {
			throw new TypeError("'d' is not nullable");
		}
		else if(!Type.isArray(d)) {
			throw new TypeError("'d' is not of type 'Array'");
		}
		foobar(a, b, c, d);
	}
};
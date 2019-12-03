var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function __ks_foobar_0() {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		let __ks_i = -1;
		let __ks__;
		let a = arguments.length > 1 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : "hello";
		let b = arguments[++__ks_i];
		if(b === void 0 || b === null) {
			throw new TypeError("'b' is not nullable");
		}
		else if(!Type.isString(b)) {
			throw new TypeError("'b' is not of type 'String'");
		}
		return 1;
	}
	function __ks_foobar_1() {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		let __ks_i = -1;
		let __ks__;
		let a = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : "hello";
		let b = arguments[++__ks_i];
		if(b === void 0 || b === null) {
			throw new TypeError("'b' is not nullable");
		}
		else if(!Type.isString(b)) {
			throw new TypeError("'b' is not of type 'String'");
		}
		let c = arguments[++__ks_i];
		if(c === void 0 || c === null) {
			throw new TypeError("'c' is not nullable");
		}
		return 2;
	}
	function __ks_foobar_2() {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		let __ks_i = -1;
		let __ks__;
		let a = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : "hello";
		let b = arguments[++__ks_i];
		if(b === void 0 || b === null) {
			throw new TypeError("'b' is not nullable");
		}
		let c = arguments[++__ks_i];
		if(c === void 0 || c === null) {
			throw new TypeError("'c' is not nullable");
		}
		return 3;
	}
	function foobar() {
		if(arguments.length === 1) {
			return __ks_foobar_0(...arguments);
		}
		else if(arguments.length === 2) {
			if(Type.isString(arguments[0])) {
				return __ks_foobar_1(...arguments);
			}
			else if(Type.isValue(arguments[0])) {
				return __ks_foobar_2(...arguments);
			}
			else {
				return __ks_foobar_0(...arguments);
			}
		}
		else if(arguments.length === 3) {
			if(Type.isString(arguments[1])) {
				return __ks_foobar_1(...arguments);
			}
			else {
				return __ks_foobar_2(...arguments);
			}
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};
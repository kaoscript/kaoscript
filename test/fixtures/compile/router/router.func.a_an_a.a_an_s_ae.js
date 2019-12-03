var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function __ks_foobar_0(a) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(a === void 0 || a === null) {
			throw new TypeError("'a' is not nullable");
		}
		let __ks_i = 0;
		let __ks__;
		let b = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 ? __ks__ : null;
		let c = arguments[++__ks_i];
		if(c === void 0 || c === null) {
			throw new TypeError("'c' is not nullable");
		}
		console.log(a, b, c);
	}
	function __ks_foobar_1(a) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(a === void 0 || a === null) {
			throw new TypeError("'a' is not nullable");
		}
		let __ks_i = 0;
		let __ks__;
		let b = arguments.length > 3 && (__ks__ = arguments[++__ks_i]) !== void 0 ? __ks__ : null;
		let c = arguments[++__ks_i];
		if(c === void 0 || c === null) {
			throw new TypeError("'c' is not nullable");
		}
		else if(!Type.isString(c)) {
			throw new TypeError("'c' is not of type 'String'");
		}
		let d = arguments[++__ks_i];
		if(d === void 0 || d === null) {
			throw new TypeError("'d' is not nullable");
		}
		console.log(a, b, c, d);
	}
	function foobar() {
		if(arguments.length === 2) {
			return __ks_foobar_0(...arguments);
		}
		else if(arguments.length === 3) {
			if(Type.isString(arguments[1])) {
				return __ks_foobar_1(...arguments);
			}
			else {
				return __ks_foobar_0(...arguments);
			}
		}
		else if(arguments.length === 4) {
			return __ks_foobar_1(...arguments);
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};
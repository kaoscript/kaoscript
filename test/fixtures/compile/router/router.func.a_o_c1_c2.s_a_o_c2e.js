var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	class Quxbaz {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	function foobar() {
		if(arguments.length === 4 && Type.isDictionary(arguments[2])) {
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
			let c = arguments[++__ks_i];
			if(c === void 0 || c === null) {
				throw new TypeError("'c' is not nullable");
			}
			else if(!Type.isDictionary(c)) {
				throw new TypeError("'c' is not of type 'Dictionary'");
			}
			let d = arguments[++__ks_i];
			if(d === void 0 || d === null) {
				throw new TypeError("'d' is not nullable");
			}
			else if(!Type.isClassInstance(d, Quxbaz)) {
				throw new TypeError("'d' is not of type 'Quxbaz'");
			}
			return b;
		}
		else if(arguments.length === 4) {
			let __ks_i = -1;
			let a = arguments[++__ks_i];
			if(a === void 0 || a === null) {
				throw new TypeError("'a' is not nullable");
			}
			let b = arguments[++__ks_i];
			if(b === void 0 || b === null) {
				throw new TypeError("'b' is not nullable");
			}
			else if(!Type.isDictionary(b)) {
				throw new TypeError("'b' is not of type 'Dictionary'");
			}
			let c = arguments[++__ks_i];
			if(c === void 0 || c === null) {
				throw new TypeError("'c' is not nullable");
			}
			else if(!Type.isClassInstance(c, Foobar)) {
				throw new TypeError("'c' is not of type 'Foobar'");
			}
			let d = arguments[++__ks_i];
			if(d === void 0 || d === null) {
				throw new TypeError("'d' is not nullable");
			}
			else if(!Type.isClassInstance(d, Quxbaz)) {
				throw new TypeError("'d' is not of type 'Quxbaz'");
			}
			return a;
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};
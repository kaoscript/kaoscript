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
		if(arguments.length === 4 && Type.isString(arguments[0])) {
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
		else if(arguments.length === 5) {
			let __ks_i = -1;
			let a = arguments[++__ks_i];
			if(a === void 0) {
				a = null;
			}
			else if(a !== null && !Type.isString(a)) {
				throw new TypeError("'a' is not of type 'String?'");
			}
			let b = arguments[++__ks_i];
			if(b === void 0 || b === null) {
				throw new TypeError("'b' is not nullable");
			}
			let c = arguments[++__ks_i];
			if(c === void 0 || c === null) {
				throw new TypeError("'c' is not nullable");
			}
			let d = arguments[++__ks_i];
			if(d === void 0 || d === null) {
				throw new TypeError("'d' is not nullable");
			}
			else if(!Type.isClassInstance(d, Foobar)) {
				throw new TypeError("'d' is not of type 'Foobar'");
			}
			let e = arguments[++__ks_i];
			if(e === void 0 || e === null) {
				throw new TypeError("'e' is not nullable");
			}
			else if(!Type.isClassInstance(e, Quxbaz)) {
				throw new TypeError("'e' is not of type 'Quxbaz'");
			}
			return c;
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};
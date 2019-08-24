var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(x) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			let __ks_i = 0;
			let __ks__;
			let y = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : 0;
			let z = arguments[++__ks_i];
			if(z === void 0 || z === null) {
				throw new TypeError("'z' is not nullable");
			}
			else if(!Type.isNumber(z)) {
				throw new TypeError("'z' is not of type 'Number'");
			}
		}
		__ks_cons_1(x) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			let __ks_i = 0;
			let __ks__;
			let y = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : 0;
			let z = arguments[++__ks_i];
			if(z === void 0 || z === null) {
				throw new TypeError("'z' is not nullable");
			}
			else if(!Type.isString(z)) {
				throw new TypeError("'z' is not of type 'String'");
			}
		}
		__ks_cons(args) {
			if(args.length === 2) {
				if(Type.isNumber(args[1])) {
					Foobar.prototype.__ks_cons_0.apply(this, args);
				}
				else {
					Foobar.prototype.__ks_cons_1.apply(this, args);
				}
			}
			else if(args.length === 3) {
				if(Type.isNumber(args[2])) {
					Foobar.prototype.__ks_cons_0.apply(this, args);
				}
				else {
					Foobar.prototype.__ks_cons_1.apply(this, args);
				}
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
};
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
		__ks_func_foobar_0(pattern) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(pattern === void 0 || pattern === null) {
				throw new TypeError("'pattern' is not nullable");
			}
			else if(!Type.isString(pattern)) {
				throw new TypeError("'pattern' is not of type 'String'");
			}
			let __ks_i = 0;
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
		}
		__ks_func_foobar_1(pattern) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(pattern === void 0 || pattern === null) {
				throw new TypeError("'pattern' is not nullable");
			}
			else if(!Type.isRegExp(pattern)) {
				throw new TypeError("'pattern' is not of type 'RegExp'");
			}
			let __ks_i = 0;
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
		}
		foobar() {
			if(arguments.length >= 1 && arguments.length <= 3) {
				if(Type.isString(arguments[0])) {
					return Foobar.prototype.__ks_func_foobar_0.apply(this, arguments);
				}
				else {
					return Foobar.prototype.__ks_func_foobar_1.apply(this, arguments);
				}
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};
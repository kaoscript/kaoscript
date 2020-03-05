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
		__ks_func_foobar_0(c) {
			if(c === void 0 || c === null) {
				c = true;
			}
			else if(!Type.isBoolean(c)) {
				throw new TypeError("'c' is not of type 'Boolean'");
			}
			return 0;
		}
		__ks_func_foobar_1(c, d) {
			if(c === void 0 || c === null) {
				c = 0;
			}
			else if(!(Type.isNumber(c) || Type.isString(c))) {
				throw new TypeError("'c' is not of type 'Number' or 'String'");
			}
			if(d === void 0 || d === null) {
				d = 0;
			}
			else if(!(Type.isNumber(d) || Type.isString(d))) {
				throw new TypeError("'d' is not of type 'Number' or 'String'");
			}
			return 1;
		}
		__ks_func_foobar_2(c, d, e, f) {
			if(arguments.length < 3) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
			}
			if(c === void 0 || c === null) {
				throw new TypeError("'c' is not nullable");
			}
			else if(!(Type.isNumber(c) || Type.isString(c))) {
				throw new TypeError("'c' is not of type 'Number' or 'String'");
			}
			if(d === void 0 || d === null) {
				throw new TypeError("'d' is not nullable");
			}
			else if(!(Type.isNumber(d) || Type.isString(d))) {
				throw new TypeError("'d' is not of type 'Number' or 'String'");
			}
			if(e === void 0 || e === null) {
				throw new TypeError("'e' is not nullable");
			}
			else if(!(Type.isDictionary(e) || Type.isString(e))) {
				throw new TypeError("'e' is not of type 'Dictionary' or 'String'");
			}
			if(f === void 0 || f === null) {
				f = true;
			}
			else if(!Type.isBoolean(f)) {
				throw new TypeError("'f' is not of type 'Boolean'");
			}
			return 2;
		}
		foobar() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_foobar_0.apply(this, arguments);
			}
			else if(arguments.length === 1) {
				if(Type.isBoolean(arguments[0])) {
					return Foobar.prototype.__ks_func_foobar_0.apply(this, arguments);
				}
				else {
					return Foobar.prototype.__ks_func_foobar_1.apply(this, arguments);
				}
			}
			else if(arguments.length === 2) {
				return Foobar.prototype.__ks_func_foobar_1.apply(this, arguments);
			}
			else if(arguments.length === 3 || arguments.length === 4) {
				return Foobar.prototype.__ks_func_foobar_2.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};
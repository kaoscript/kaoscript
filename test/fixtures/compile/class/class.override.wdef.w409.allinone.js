var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isString(x)) {
			throw new TypeError("'x' is not of type 'String'");
		}
		return x;
	}
	function quxbaz(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isNumber(x)) {
			throw new TypeError("'x' is not of type 'Number'");
		}
		return x;
	}
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
		__ks_func_foobar_0(x) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isBoolean(x)) {
				throw new TypeError("'x' is not of type 'Boolean'");
			}
		}
		__ks_func_foobar_1(x, y) {
			if(x === void 0 || x === null) {
				x = "";
			}
			else if(!Type.isString(x)) {
				throw new TypeError("'x' is not of type 'String'");
			}
			if(y === void 0 || y === null) {
				y = this.__ks_default_0_0(x);
			}
			else if(!Type.isString(y)) {
				throw new TypeError("'y' is not of type 'String'");
			}
			return x;
		}
		__ks_default_0_0(x) {
			return foobar(x);
		}
		foobar() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_foobar_1.apply(this, arguments);
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
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	class Quxbaz extends Foobar {
		__ks_init() {
			Foobar.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			Foobar.prototype.__ks_cons.call(this, args);
		}
		__ks_func_foobar_0(x, y) {
			if(x === void 0 || x === null) {
				x = "";
			}
			else if(!Type.isString(x)) {
				throw new TypeError("'x' is not of type 'String'");
			}
			if(y === void 0 || y === null) {
				y = this.__ks_default_0_0(x);
			}
			else if(!Type.isString(y)) {
				throw new TypeError("'y' is not of type 'String'");
			}
			return y;
		}
		__ks_func_foobar_1(x) {
			if(x === void 0 || x === null) {
				x = this.__ks_default_1_0();
			}
			else if(!Type.isNumber(x)) {
				throw new TypeError("'x' is not of type 'Number'");
			}
		}
		__ks_default_1_0() {
			return quxbaz(42);
		}
		foobar() {
			if(arguments.length === 0) {
				return Quxbaz.prototype.__ks_func_foobar_1.apply(this, arguments);
			}
			else if(arguments.length === 1) {
				if(Type.isNumber(arguments[0])) {
					return Quxbaz.prototype.__ks_func_foobar_1.apply(this, arguments);
				}
				else if(Type.isString(arguments[0])) {
					return Quxbaz.prototype.__ks_func_foobar_0.apply(this, arguments);
				}
			}
			else if(arguments.length === 2) {
				if(Type.isString(arguments[0]) && Type.isString(arguments[1])) {
					return Quxbaz.prototype.__ks_func_foobar_0.apply(this, arguments);
				}
			}
			return Foobar.prototype.foobar.apply(this, arguments);
		}
	}
	return {
		Foobar: Foobar,
		Quxbaz: Quxbaz
	};
};
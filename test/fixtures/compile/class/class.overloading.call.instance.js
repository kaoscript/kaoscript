var {Helper, Type} = require("@kaoscript/runtime");
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
		__ks_func_foobar_0(x) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isString(x)) {
				throw new TypeError("'x' is not of type 'String'");
			}
			return "quxbaz";
		}
		__ks_func_foobar_1(x) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isNumber(x)) {
				throw new TypeError("'x' is not of type 'Number'");
			}
			return 42;
		}
		foobar() {
			if(arguments.length === 1) {
				if(Type.isNumber(arguments[0])) {
					return Foobar.prototype.__ks_func_foobar_1.apply(this, arguments);
				}
				else {
					return Foobar.prototype.__ks_func_foobar_0.apply(this, arguments);
				}
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_quxbaz_0(a) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(a === void 0 || a === null) {
				throw new TypeError("'a' is not nullable");
			}
			console.log(this.foobar("foo"));
			console.log(Helper.toString(this.foobar(0)));
			console.log(Helper.toString(this.foobar(a)));
		}
		quxbaz() {
			if(arguments.length === 1) {
				return Foobar.prototype.__ks_func_quxbaz_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};
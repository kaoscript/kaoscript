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
		__ks_func_value_0(value) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			this._value = value;
		}
		value() {
			if(arguments.length === 1) {
				return Foobar.prototype.__ks_func_value_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};
var Dictionary = require("@kaoscript/runtime").Dictionary;
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
		__ks_func_data_0(values) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(values === void 0 || values === null) {
				throw new TypeError("'values' is not nullable");
			}
			values.push((() => {
				const d = new Dictionary();
				d.value = this._value.name();
				return d;
			})());
		}
		data() {
			if(arguments.length === 1) {
				return Foobar.prototype.__ks_func_data_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};
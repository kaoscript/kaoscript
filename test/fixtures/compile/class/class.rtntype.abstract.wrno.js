var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Master {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._value = "";
		}
		__ks_init() {
			Master.prototype.__ks_init_1.call(this);
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	class Foobar extends Master {
		__ks_init() {
			Master.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			Master.prototype.__ks_cons.call(this, args);
		}
		__ks_func_value_0() {
			return this._value;
		}
		__ks_func_value_1(value) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			else if(!Type.isString(value)) {
				throw new TypeError("'value' is not of type 'String'");
			}
			this._value = value;
			return this;
		}
		value() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_value_0.apply(this);
			}
			else if(arguments.length === 1) {
				return Foobar.prototype.__ks_func_value_1.apply(this, arguments);
			}
			else if(Master.prototype.value) {
				return Master.prototype.value.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	const f = new Foobar();
	console.log(f.value("foobar").value());
	return {
		Master: Master,
		Foobar: Foobar
	};
};
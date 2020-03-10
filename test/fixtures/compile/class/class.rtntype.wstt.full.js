var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_0() {
			this._value = "";
		}
		__ks_init() {
			Foobar.prototype.__ks_init_0.call(this);
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
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
			throw new SyntaxError("Wrong number of arguments");
		}
		static __ks_sttc_instance_0() {
			return Foobar._instance;
		}
		static __ks_sttc_instance_1(instance) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(instance === void 0 || instance === null) {
				throw new TypeError("'instance' is not nullable");
			}
			else if(!Type.isClassInstance(instance, Foobar)) {
				throw new TypeError("'instance' is not of type 'Foobar'");
			}
			Foobar._instance = instance;
		}
		static instance() {
			if(arguments.length === 0) {
				return Foobar.__ks_sttc_instance_0.apply(this);
			}
			else if(arguments.length === 1) {
				return Foobar.__ks_sttc_instance_1.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	Foobar._instance = new Foobar();
	console.log(Foobar.instance().value());
	return {
		Foobar: Foobar
	};
};
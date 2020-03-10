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
	}
	Foobar.prototype.__ks_func_value_0 = function() {
		return this._value;
	};
	Foobar.prototype.__ks_func_value_1 = function(value) {
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
	};
	Foobar.prototype.value = function() {
		if(arguments.length === 0) {
			return Foobar.prototype.__ks_func_value_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Foobar.prototype.__ks_func_value_1.apply(this, arguments);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	const f = new Foobar();
	console.log(f.value("foobar").value());
	return {
		Foobar: Foobar
	};
};
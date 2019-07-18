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
	}
	Foobar.prototype.__ks_func_foobar_0 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
	};
	Foobar.prototype.__ks_func_foobar_1 = function(...values) {
	};
	Foobar.prototype.foobar = function() {
		if(arguments.length === 1) {
			return Foobar.prototype.__ks_func_foobar_0.apply(this, arguments);
		}
		else {
			return Foobar.prototype.__ks_func_foobar_1.apply(this, arguments);
		}
	};
};
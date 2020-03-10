module.exports = function() {
	var __ks_Array = {};
	__ks_Array.__ks_func_pushUniq_0 = function(...args) {
		return this;
	};
	__ks_Array._im_pushUniq = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		return __ks_Array.__ks_func_pushUniq_0.apply(that, args);
	};
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_0() {
			this.values = [];
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
	const foobar = new Foobar();
	__ks_Array._im_pushUniq(foobar.values, 42);
};
module.exports = function() {
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_0() {
			this._x = 42;
		}
		__ks_init() {
			Foobar.prototype.__ks_init_0.call(this);
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_x_0() {
			return this._x;
		}
		x() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_x_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_y_0() {
			return this._x;
		}
		y() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_y_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	return {
		Foobar: Foobar
	};
};
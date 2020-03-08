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
		__ks_func_x_0() {
			return this._x;
		}
		x() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_x_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	class Quxbaz {
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
	return {
		Foobar: Foobar,
		Quxbaz: Quxbaz
	};
};
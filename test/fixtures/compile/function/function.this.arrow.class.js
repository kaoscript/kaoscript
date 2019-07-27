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
		__ks_func_foobar_0() {
			const fn = (...__ks_arguments) => {
				if(__ks_arguments.length < 1) {
					throw new SyntaxError("Wrong number of arguments (" + __ks_arguments.length + " for 1)");
				}
				let __ks_i = -1;
				let data = __ks_arguments[++__ks_i];
				if(data === void 0 || data === null) {
					throw new TypeError("'data' is not nullable");
				}
				return new Quxbaz(data, this._foobar);
			};
		}
		foobar() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_foobar_0.apply(this);
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
		__ks_cons_0(data, foobar) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(data === void 0 || data === null) {
				throw new TypeError("'data' is not nullable");
			}
			if(foobar === void 0 || foobar === null) {
				throw new TypeError("'foobar' is not nullable");
			}
		}
		__ks_cons(args) {
			if(args.length === 2) {
				Quxbaz.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
};
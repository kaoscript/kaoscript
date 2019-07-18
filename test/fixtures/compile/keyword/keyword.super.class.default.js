module.exports = function() {
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0() {
		}
		__ks_cons(args) {
			if(args.length === 0) {
				Foobar.prototype.__ks_cons_0.apply(this);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_foobar_0() {
		}
		foobar() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_foobar_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	class Quzbaz extends Foobar {
		__ks_init() {
			Foobar.prototype.__ks_init.call(this);
		}
		__ks_cons_0() {
			Foobar.prototype.__ks_cons.call(this, []);
		}
		__ks_cons(args) {
			if(args.length === 0) {
				Quzbaz.prototype.__ks_cons_0.apply(this);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_foobar_0() {
			super.foobar();
		}
		foobar() {
			if(arguments.length === 0) {
				return Quzbaz.prototype.__ks_func_foobar_0.apply(this);
			}
			return Foobar.prototype.foobar.apply(this, arguments);
		}
	}
};
module.exports = function() {
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_0() {
			this.PI = 42;
		}
		__ks_init() {
			Foobar.prototype.__ks_init_0.call(this);
		}
		__ks_cons_0() {
			this.PI = 42;
		}
		__ks_cons(args) {
			if(args.length === 0) {
				Foobar.prototype.__ks_cons_0.apply(this);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
};
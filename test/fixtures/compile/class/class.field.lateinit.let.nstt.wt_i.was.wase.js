module.exports = function() {
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0() {
			this.PI = 42;
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
module.exports = function() {
	class ClassA {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0() {
			try {
				foo();
			}
			catch(error) {
				throw error;
			}
		}
		__ks_cons(args) {
			if(args.length === 0) {
				ClassA.prototype.__ks_cons_0.apply(this);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		}
	}
};
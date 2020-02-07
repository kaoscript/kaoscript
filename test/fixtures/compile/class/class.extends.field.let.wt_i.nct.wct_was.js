module.exports = function() {
	class ClassA {
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
	class ClassB extends ClassA {
		__ks_init() {
			ClassA.prototype.__ks_init.call(this);
		}
		__ks_cons_0() {
			ClassA.prototype.__ks_cons.call(this, []);
			this._x = 1;
		}
		__ks_cons(args) {
			if(args.length === 0) {
				ClassB.prototype.__ks_cons_0.apply(this);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
};
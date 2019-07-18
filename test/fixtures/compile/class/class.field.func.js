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
		__ks_func_foo_0() {
			this._x();
		}
		foo() {
			if(arguments.length === 0) {
				return ClassA.prototype.__ks_func_foo_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};
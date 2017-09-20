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
				throw new SyntaxError("wrong number of arguments");
			}
		}
	}
	class ClassB extends ClassA {
		__ks_init() {
			ClassA.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			ClassA.prototype.__ks_cons.call(this, args);
		}
		__ks_func_toString_0() {
			return "hello";
		}
		toString() {
			if(arguments.length === 0) {
				return ClassB.prototype.__ks_func_toString_0.apply(this);
			}
			else if(ClassA.prototype.toString) {
				return ClassA.prototype.toString.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
};
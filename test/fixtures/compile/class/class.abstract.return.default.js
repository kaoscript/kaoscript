module.exports = function() {
	class Shape {
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
	class Rectangle extends Shape {
		__ks_init() {
			Shape.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			Shape.prototype.__ks_cons.call(this, args);
		}
		__ks_func_clone_0() {
			return this;
		}
		clone() {
			if(arguments.length === 0) {
				return Rectangle.prototype.__ks_func_clone_0.apply(this);
			}
			else if(Shape.prototype.clone) {
				return Shape.prototype.clone.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};
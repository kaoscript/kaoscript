module.exports = function() {
	class Type {
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
	class FunctionType extends Type {
		__ks_init() {
			Type.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			Type.prototype.__ks_cons.call(this, args);
		}
		__ks_func_equals_0(b) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(b === void 0) {
				b = null;
			}
			return true;
		}
		equals() {
			if(arguments.length === 1) {
				return FunctionType.prototype.__ks_func_equals_0.apply(this, arguments);
			}
			else if(Type.prototype.equals) {
				return Type.prototype.equals.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};
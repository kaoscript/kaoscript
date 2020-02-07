var {Helper, Type} = require("@kaoscript/runtime");
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
		__ks_func_foobar_0() {
			return this;
		}
		foobar() {
			if(arguments.length === 0) {
				return ClassA.prototype.__ks_func_foobar_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	class ClassX extends ClassA {
		__ks_init_1() {
			this._foobar = new ClassA();
		}
		__ks_init() {
			ClassA.prototype.__ks_init.call(this);
			ClassX.prototype.__ks_init_1.call(this);
		}
		__ks_cons(args) {
			ClassA.prototype.__ks_cons.call(this, args);
		}
		__ks_func_foobar_0() {
			return this._foobar;
		}
		__ks_func_foobar_1(foobar) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(foobar === void 0 || foobar === null) {
				throw new TypeError("'foobar' is not nullable");
			}
			else if(!Type.isClassInstance(foobar, ClassA)) {
				throw new TypeError("'foobar' is not of type 'ClassA'");
			}
			this._foobar = foobar;
			return this;
		}
		foobar() {
			if(arguments.length === 0) {
				return ClassX.prototype.__ks_func_foobar_0.apply(this);
			}
			else if(arguments.length === 1) {
				return ClassX.prototype.__ks_func_foobar_1.apply(this, arguments);
			}
			return ClassA.prototype.foobar.apply(this, arguments);
		}
	}
	class ClassY extends ClassA {
		__ks_init_1() {
			this._foobar = new ClassA();
		}
		__ks_init() {
			ClassA.prototype.__ks_init.call(this);
			ClassY.prototype.__ks_init_1.call(this);
		}
		__ks_cons(args) {
			ClassA.prototype.__ks_cons.call(this, args);
		}
		__ks_func_quxbaz_0() {
			this._foobar = Helper.cast(this._foobar, "ClassX", false, ClassX, "Class").foobar();
		}
		quxbaz() {
			if(arguments.length === 0) {
				return ClassY.prototype.__ks_func_quxbaz_0.apply(this);
			}
			else if(ClassA.prototype.quxbaz) {
				return ClassA.prototype.quxbaz.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};
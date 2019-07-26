module.exports = function() {
	class Foobar {
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
		__ks_func_xyz_0(x, y, z) {
			if(arguments.length < 3) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			if(y === void 0 || y === null) {
				throw new TypeError("'y' is not nullable");
			}
			if(z === void 0 || z === null) {
				throw new TypeError("'z' is not nullable");
			}
		}
		xyz() {
			if(arguments.length === 3) {
				return Foobar.prototype.__ks_func_xyz_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	class Quxbaz extends Foobar {
		__ks_init() {
			Foobar.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			Foobar.prototype.__ks_cons.call(this, args);
		}
		__ks_func_xyz_0(...xyz) {
		}
		xyz() {
			return Quxbaz.prototype.__ks_func_xyz_0.apply(this, arguments);
		}
	}
};
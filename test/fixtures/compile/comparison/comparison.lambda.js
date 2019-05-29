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
				throw new SyntaxError("wrong number of arguments");
			}
		}
		__ks_func_qux_0() {
			const test = function(x, y) {
				if(arguments.length < 2) {
					throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
				}
				if(x === void 0 || x === null) {
					throw new TypeError("'x' is not nullable");
				}
				if(y === void 0 || y === null) {
					throw new TypeError("'y' is not nullable");
				}
				return x === y;
			};
		}
		qux() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_qux_0.apply(this);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
};
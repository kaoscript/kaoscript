module.exports = function() {
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(data, __ks_arguments_1) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(data === void 0 || data === null) {
				throw new TypeError("'data' is not nullable");
			}
			if(__ks_arguments_1 === void 0 || __ks_arguments_1 === null) {
				throw new TypeError("'arguments' is not nullable");
			}
		}
		__ks_cons(args) {
			if(args.length === 2) {
				Foobar.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	const builder = function(data, __ks_arguments_1) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(data === void 0 || data === null) {
			throw new TypeError("'data' is not nullable");
		}
		if(__ks_arguments_1 === void 0 || __ks_arguments_1 === null) {
			throw new TypeError("'arguments' is not nullable");
		}
		return new Foobar(data, __ks_arguments_1);
	};
};
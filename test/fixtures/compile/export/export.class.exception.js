module.exports = function() {
	var __ks_Error = {};
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
		__ks_func_foo_0() {
		}
		foo() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_foo_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	class Exception extends Error {
		constructor() {
			super(...arguments);
			this.constructor.prototype.__ks_init();
		}
		__ks_init() {
		}
		static __ks_sttc_throwFoobar_0(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
		}
		static throwFoobar() {
			if(arguments.length === 1) {
				return Exception.__ks_sttc_throwFoobar_0.apply(this, arguments);
			}
			else if(Error.throwFoobar) {
				return Error.throwFoobar.apply(null, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	return {
		Foobar: Foobar,
		Exception: Exception
	};
};
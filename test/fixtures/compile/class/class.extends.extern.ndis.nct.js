module.exports = function() {
	var __ks_Error = {};
	class FooError extends Error {
		constructor() {
			super(...arguments);
			this.constructor.prototype.__ks_init();
		}
		__ks_init() {
		}
		__ks_func_toString_0() {
			return "FooError: " + this.message;
		}
		toString() {
			if(arguments.length === 0) {
				return FooError.prototype.__ks_func_toString_0.apply(this);
			}
			return Error.prototype.toString.apply(this, arguments);
		}
	}
	return {
		__ks_Error: __ks_Error,
		FooError: FooError
	};
};
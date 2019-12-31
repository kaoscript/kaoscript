var Type = require("@kaoscript/runtime").Type;
module.exports = function(__ks_0, __ks___ks_0, __ks_Error) {
	if(Type.isValue(__ks_0)) {
		Foobar = __ks_0;
		__ks_Foobar = __ks___ks_0;
	}
	else {
		__ks_Foobar = {};
	}
	if(!Type.isValue(__ks_Error)) {
		__ks_Error = {};
	}
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
		Foobar: Foobar,
		__ks_Foobar: __ks_Foobar,
		__ks_Error: __ks_Error,
		FooError: FooError
	};
};
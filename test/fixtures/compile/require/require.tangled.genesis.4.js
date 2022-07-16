const {Type} = require("@kaoscript/runtime");
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
		toString() {
			return this.__ks_func_toString_rt.call(null, this, this, arguments);
		}
		__ks_func_toString_0() {
			return "FooError: " + this.message;
		}
		__ks_func_toString_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_toString_0.call(that);
			}
			return super.toString.apply(that, args);
		}
	}
	return {
		Foobar,
		__ks_Foobar,
		__ks_Error,
		FooError
	};
};
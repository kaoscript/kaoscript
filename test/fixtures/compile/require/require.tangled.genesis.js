var Type = require("@kaoscript/runtime").Type;
function __ks_require(__ks_0, __ks___ks_0, __ks_1, __ks___ks_1) {
	var req = [];
	if(Type.isValue(__ks_0)) {
		req.push(__ks_0, __ks___ks_0);
	}
	else {
		req.push(Foobar, typeof __ks_Foobar === "undefined" ? {} : __ks_Foobar);
	}
	if(Type.isValue(__ks_1)) {
		req.push(__ks_1, __ks___ks_1);
	}
	else {
		req.push(Error, typeof __ks_Error === "undefined" ? {} : __ks_Error);
	}
	return req;
}
module.exports = function(__ks_0, __ks___ks_0, __ks_1, __ks___ks_1) {
	var [Foobar, __ks_Foobar, Error, __ks_Error] = __ks_require(__ks_0, __ks___ks_0, __ks_1, __ks___ks_1);
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
		Error: Error,
		__ks_Error: __ks_Error,
		FooError: FooError
	};
};
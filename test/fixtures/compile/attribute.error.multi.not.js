module.exports = function() {
	var __ks_Error = {};
	class NotImplementedError extends Error {
		constructor() {
			super();
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			Error.prototype.constructor.call(this, args);
		}
	}
	class NotSupportedError extends Error {
		constructor() {
			super();
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			Error.prototype.constructor.call(this, args);
		}
	}
	throw new NotImplementedError();
}
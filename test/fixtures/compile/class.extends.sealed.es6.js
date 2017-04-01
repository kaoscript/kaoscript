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
		__ks_cons_0(message) {
			if(message === void 0 || message === null) {
				message = "Not Implemented";
			}
			this.message = message;
		}
		__ks_cons(args) {
			if(args.length >= 0 && args.length <= 1) {
				NotImplementedError.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		}
	}
}
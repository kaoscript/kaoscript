var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Error = {};
	class Exception extends Error {
		constructor() {
			super();
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(message) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(message === void 0 || message === null) {
				throw new TypeError("'message' is not nullable");
			}
			else if(!Type.isString(message)) {
				throw new TypeError("'message' is not of type 'String'");
			}
			this.message = message;
			this.name = this.constructor.name;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Exception.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				Error.prototype.constructor.call(this, args);
			}
		}
	}
}
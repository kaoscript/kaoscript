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
			this.message = message;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Exception.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				Error.prototype.constructor.call(this, args);
			}
		}
		static __ks_sttc_throw_0(message) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(message === void 0 || message === null) {
				throw new TypeError("'message' is not nullable");
			}
			throw new Exception(message);
		}
		static throw() {
			if(arguments.length === 1) {
				return Exception.__ks_sttc_throw_0.apply(this, arguments);
			}
			else if(Error.throw) {
				return Error.throw.apply(null, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
	try {
		Exception.throw("foobar");
	}
	catch(__ks_0) {
	}
}
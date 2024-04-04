const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Exception extends Error {
		constructor(message) {
			super();
			this.constructor.prototype.__ks_init();
			this.message = message;
		}
		__ks_init() {
		}
		static __ks_sttc_throw_0(message) {
			throw new Exception(message);
		}
		static throw() {
			const t0 = Type.isValue;
			if(arguments.length === 1) {
				if(t0(arguments[0])) {
					return Exception.__ks_sttc_throw_0(arguments[0]);
				}
			}
			if(Error.throw) {
				return Error.throw.apply(null, arguments);
			}
			throw Helper.badArgs();
		}
	}
	try {
		Exception.__ks_sttc_throw_0("foobar");
	}
	catch(__ks_0) {
	}
};
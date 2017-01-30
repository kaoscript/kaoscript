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
		__ks_cons(args) {
			Error.prototype.constructor.call(this, args);
		}
	}
	Exception.__ks_reflect = {
		inits: 0,
		constructors: [],
		destructors: 0,
		instanceVariables: {},
		classVariables: {},
		instanceMethods: {},
		classMethods: {}
	};
	throw new Error();
}
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
	NotImplementedError.__ks_reflect = {
		inits: 0,
		constructors: [],
		destructors: 0,
		instanceVariables: {},
		classVariables: {},
		instanceMethods: {},
		classMethods: {}
	};
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
	NotSupportedError.__ks_reflect = {
		inits: 0,
		constructors: [],
		destructors: 0,
		instanceVariables: {},
		classVariables: {},
		instanceMethods: {},
		classMethods: {}
	};
	throw new NotImplementedError();
}
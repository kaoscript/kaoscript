var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Error = {};
	class Exception extends Error {
		constructor() {
			const __ks_cons_0 = (__ks_arguments) => {
				let __ks_i = -1;
				let message = __ks_arguments[++__ks_i];
				if(message === void 0 || message === null) {
					throw new TypeError("'message' is not nullable");
				}
				else if(!Type.isString(message)) {
					throw new TypeError("'message' is not of type 'String'");
				}
				super();
				this.__ks_init();
				this.message = message;
				this.name = this.constructor.name;
			};
			const __ks_cons_1 = (__ks_arguments) => {
				let __ks_i = -1;
				let message = __ks_arguments[++__ks_i];
				if(message === void 0 || message === null) {
					throw new TypeError("'message' is not nullable");
				}
				else if(!Type.isString(message)) {
					throw new TypeError("'message' is not of type 'String'");
				}
				let fileName = __ks_arguments[++__ks_i];
				if(fileName === void 0 || fileName === null) {
					throw new TypeError("'fileName' is not nullable");
				}
				else if(!Type.isString(fileName)) {
					throw new TypeError("'fileName' is not of type 'String'");
				}
				let lineNumber = __ks_arguments[++__ks_i];
				if(lineNumber === void 0 || lineNumber === null) {
					throw new TypeError("'lineNumber' is not nullable");
				}
				else if(!Type.isNumber(lineNumber)) {
					throw new TypeError("'lineNumber' is not of type 'Number'");
				}
				__ks_cons([message]);
				this.fileName = fileName;
				this.lineNumber = lineNumber;
			};
			const __ks_cons = (__ks_arguments) => {
				if(__ks_arguments.length === 1) {
					__ks_cons_0(__ks_arguments);
				}
				else if(__ks_arguments.length === 3) {
					__ks_cons_1(__ks_arguments);
				}
				else {
					throw new SyntaxError("wrong number of arguments");
				}
			};
			__ks_cons(arguments);
		}
		__ks_init_1() {
			this.fileName = null;
			this.lineNumber = 0;
		}
		__ks_init() {
			Exception.prototype.__ks_init_1.call(this);
		}
	}
};
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Error = {};
	class Exception extends Error {
		constructor() {
			const __ks_cons_0 = (message) => {
				super();
				this.__ks_init();
				this.message = message;
				this.name = this.constructor.name;
			};
			const __ks_cons_1 = (message, fileName, lineNumber) => {
				if(fileName === void 0) {
					fileName = null;
				}
				__ks_cons_0(message);
				this.fileName = fileName;
				this.lineNumber = lineNumber;
			};
			const __ks_cons_rt = (args) => {
				const t0 = Type.isString;
				const t1 = value => Type.isString(value) || Type.isNull(value);
				const t2 = Type.isNumber;
				if(args.length === 1) {
					if(t0(args[0])) {
						return __ks_cons_0(args[0]);
					}
					throw Helper.badArgs();
				}
				if(args.length === 3) {
					if(t0(args[0]) && t1(args[1]) && t2(args[2])) {
						return __ks_cons_1(args[0], args[1], args[2]);
					}
				}
				throw Helper.badArgs();
			};
			__ks_cons_rt(arguments);
		}
		__ks_init_0() {
			this.fileName = null;
			this.lineNumber = 0;
		}
		__ks_init() {
			Exception.prototype.__ks_init_0.call(this);
		}
	}
};
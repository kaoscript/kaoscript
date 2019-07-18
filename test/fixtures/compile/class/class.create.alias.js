var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Writer {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(line) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(line === void 0 || line === null) {
				throw new TypeError("'line' is not nullable");
			}
			else if(!Type.isClass(line)) {
				throw new TypeError("'line' is not of type 'Class'");
			}
			this._line = line;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Writer.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_newLine_0(...args) {
			return new this._line(...args);
		}
		newLine() {
			return Writer.prototype.__ks_func_newLine_0.apply(this, arguments);
		}
	}
};
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Writer {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(Line) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(Line === void 0 || Line === null) {
				throw new TypeError("'Line' is not nullable");
			}
			else if(!Type.isClass(Line)) {
				throw new TypeError("'Line' is not of type 'Class'");
			}
			this.Line = Line;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Writer.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		}
		__ks_func_newLine_0(...args) {
			return new this.Line(...args);
		}
		newLine() {
			return Writer.prototype.__ks_func_newLine_0.apply(this, arguments);
		}
	}
}
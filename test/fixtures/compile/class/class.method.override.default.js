var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class LetterBox {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("wrong number of arguments");
			}
		}
		__ks_func_format_0(message) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(message === void 0 || message === null) {
				throw new TypeError("'message' is not nullable");
			}
			else if(!Type.isString(message)) {
				throw new TypeError("'message' is not of type 'String'");
			}
			return message.toUpperCase();
		}
		format() {
			if(arguments.length === 1) {
				return LetterBox.prototype.__ks_func_format_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
	LetterBox.prototype.__ks_func_format_0 = function(message) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(message === void 0 || message === null) {
			throw new TypeError("'message' is not nullable");
		}
		else if(!Type.isString(message)) {
			throw new TypeError("'message' is not of type 'String'");
		}
		return message.toLowerCase();
	};
};
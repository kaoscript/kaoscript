var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class LetterBox {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(messages) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(messages === void 0 || messages === null) {
				throw new TypeError("'messages' is not nullable");
			}
			else if(!Type.isArray(messages)) {
				throw new TypeError("'messages' is not of type 'Array'");
			}
			this._messages = messages;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				LetterBox.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		}
		__ks_func_build_0() {
			return Helper.mapArray(this._messages, Helper.vcurry(function(message) {
				return this.format(message);
			}, this));
		}
		build() {
			if(arguments.length === 0) {
				return LetterBox.prototype.__ks_func_build_0.apply(this);
			}
			throw new SyntaxError("wrong number of arguments");
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
};
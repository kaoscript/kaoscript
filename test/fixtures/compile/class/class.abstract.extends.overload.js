var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class AbstractGreetings {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	class Greetings extends AbstractGreetings {
		__ks_init() {
			AbstractGreetings.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			AbstractGreetings.prototype.__ks_cons.call(this, args);
		}
		__ks_func_message_0() {
			return this._message;
		}
		__ks_func_message_1(message) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(message === void 0 || message === null) {
				throw new TypeError("'message' is not nullable");
			}
			else if(!Type.isString(message)) {
				throw new TypeError("'message' is not of type 'String'");
			}
			this._message = message;
			return this;
		}
		message() {
			if(arguments.length === 0) {
				return Greetings.prototype.__ks_func_message_0.apply(this);
			}
			else if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_message_1.apply(this, arguments);
			}
			else if(AbstractGreetings.prototype.message) {
				return AbstractGreetings.prototype.message.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};
var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Greetings {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_0() {
			this._message = "Hello!";
		}
		__ks_init() {
			Greetings.prototype.__ks_init_0.call(this);
		}
		__ks_cons_0() {
		}
		__ks_cons_1(message) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(message === void 0 || message === null) {
				throw new TypeError("'message' is not nullable");
			}
			this._message = message;
		}
		__ks_cons_2(number) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(number === void 0 || number === null) {
				throw new TypeError("'number' is not nullable");
			}
			else if(!Type.isNumber(number)) {
				throw new TypeError("'number' is not of type 'Number'");
			}
			Greetings.prototype.__ks_cons.call(this, [Helper.toString(number)]);
		}
		__ks_cons(args) {
			if(args.length === 0) {
				Greetings.prototype.__ks_cons_0.apply(this);
			}
			else if(args.length === 1) {
				if(Type.isNumber(args[0])) {
					Greetings.prototype.__ks_cons_2.apply(this, args);
				}
				else {
					Greetings.prototype.__ks_cons_1.apply(this, args);
				}
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
};
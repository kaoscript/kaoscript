var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Greetings {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._message = "Hello!";
		}
		__ks_init() {
			Greetings.prototype.__ks_init_1.call(this);
		}
		__ks_cons_0() {
		}
		__ks_cons_1(message) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(message === void 0 || message === null) {
				throw new TypeError("'message' is not nullable");
			}
			else if(!Type.isString(message)) {
				throw new TypeError("'message' is not of type 'String'");
			}
			this._message = message;
		}
		__ks_cons_2(lines) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(lines === void 0 || lines === null) {
				throw new TypeError("'lines' is not nullable");
			}
			else if(!Type.isArray(lines, String)) {
				throw new TypeError("'lines' is not of type 'Array'");
			}
			Greetings.prototype.__ks_cons.call(this, [lines.join("\n")]);
		}
		__ks_cons(args) {
			if(args.length === 0) {
				Greetings.prototype.__ks_cons_0.apply(this);
			}
			else if(args.length === 1) {
				if(Type.isString(args[0])) {
					Greetings.prototype.__ks_cons_1.apply(this, args);
				}
				else {
					Greetings.prototype.__ks_cons_2.apply(this, args);
				}
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		}
	}
};
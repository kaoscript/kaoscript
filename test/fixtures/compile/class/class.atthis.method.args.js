var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Greetings {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_0() {
			this.__message = "";
		}
		__ks_init() {
			Greetings.prototype.__ks_init_0.call(this);
		}
		__ks_cons_0() {
			Greetings.prototype.__ks_cons.call(this, ["Hello!"]);
		}
		__ks_cons_1(__message) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(__message === void 0 || __message === null) {
				throw new TypeError("'__message' is not nullable");
			}
			else if(!Type.isString(__message)) {
				throw new TypeError("'__message' is not of type 'String'");
			}
			this.__message = __message;
		}
		__ks_cons(args) {
			if(args.length === 0) {
				Greetings.prototype.__ks_cons_0.apply(this);
			}
			else if(args.length === 1) {
				Greetings.prototype.__ks_cons_1.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_message_0(prefix, suffix) {
			if(prefix === void 0 || prefix === null) {
				prefix = "";
			}
			if(suffix === void 0 || suffix === null) {
				suffix = "";
			}
			return Helper.concatString(prefix, this.__message, suffix);
		}
		message() {
			if(arguments.length >= 0 && arguments.length <= 2) {
				return Greetings.prototype.__ks_func_message_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_greet_01_0(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			return Helper.concatString(this.message(), "\nIt's nice to meet you, ", name, ".");
		}
		greet_01() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_greet_01_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_greet_02_0(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			return Helper.concatString(this.message(null, "Bye!"), "\nIt's nice to meet you, ", name, ".");
		}
		greet_02() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_greet_02_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};
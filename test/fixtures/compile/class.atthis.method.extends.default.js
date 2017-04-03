var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Messenger {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._message = "";
		}
		__ks_init() {
			Messenger.prototype.__ks_init_1.call(this);
		}
		__ks_cons_0() {
			Messenger.prototype.__ks_cons.call(this, ["Hello!"]);
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
		__ks_cons(args) {
			if(args.length === 0) {
				Messenger.prototype.__ks_cons_0.apply(this);
			}
			else if(args.length === 1) {
				Messenger.prototype.__ks_cons_1.apply(this, args);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		}
		__ks_func_message_0(message) {
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
			return this;
		}
		__ks_func_message_1() {
			return this._message;
		}
		message() {
			if(arguments.length === 0) {
				return Messenger.prototype.__ks_func_message_1.apply(this);
			}
			else if(arguments.length === 1) {
				return Messenger.prototype.__ks_func_message_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
	class Greetings extends Messenger {
		__ks_init() {
			Messenger.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			Messenger.prototype.__ks_cons.call(this, args);
		}
		__ks_func_greet_01_0(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			return this._message + "\nIt's nice to meet you, " + name + ".";
		}
		greet_01() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_greet_01_0.apply(this, arguments);
			}
			else if(Messenger.prototype.greet_01) {
				return Messenger.prototype.greet_01.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_greet_02_0(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			return "" + this.message() + "\nIt's nice to meet you, " + name + ".";
		}
		greet_02() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_greet_02_0.apply(this, arguments);
			}
			else if(Messenger.prototype.greet_02) {
				return Messenger.prototype.greet_02.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_greet_03_0(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			return "" + this._message.toUpperCase() + "\nIt's nice to meet you, " + name + ".";
		}
		greet_03() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_greet_03_0.apply(this, arguments);
			}
			else if(Messenger.prototype.greet_03) {
				return Messenger.prototype.greet_03.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
}
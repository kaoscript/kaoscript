module.exports = function() {
	class Messenger {
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
		__ks_func_message_0() {
			return "Hello!";
		}
		message() {
			if(arguments.length === 0) {
				return Messenger.prototype.__ks_func_message_0.apply(this);
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
		__ks_func_greet_0(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			return "" + this.message() + "\nIt's nice to meet you, " + name + ".";
		}
		greet() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_greet_0.apply(this, arguments);
			}
			else if(Messenger.prototype.greet) {
				return Messenger.prototype.greet.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
};
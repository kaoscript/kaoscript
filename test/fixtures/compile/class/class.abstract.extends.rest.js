var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class AbstractGreetings {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._message = "";
		}
		__ks_init() {
			AbstractGreetings.prototype.__ks_init_1.call(this);
		}
		__ks_cons_0() {
			AbstractGreetings.prototype.__ks_cons.call(this, ["Hello!"]);
		}
		__ks_cons_1(message) {
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
		}
		__ks_cons(args) {
			if(args.length === 0) {
				AbstractGreetings.prototype.__ks_cons_0.apply(this);
			}
			else if(args.length === 1) {
				AbstractGreetings.prototype.__ks_cons_1.apply(this, args);
			}
			else {
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
		__ks_func_greet_0(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			return "My name is " + name + ".";
		}
		greet() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_greet_0.apply(this, arguments);
			}
			else if(AbstractGreetings.prototype.greet) {
				return AbstractGreetings.prototype.greet.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	class ProxyGreetings extends AbstractGreetings {
		__ks_init() {
			AbstractGreetings.prototype.__ks_init.call(this);
		}
		__ks_cons_0(greeting) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(greeting === void 0 || greeting === null) {
				throw new TypeError("'greeting' is not nullable");
			}
			else if(!Type.isInstance(greeting, AbstractGreetings)) {
				throw new TypeError("'greeting' is not of type 'AbstractGreetings'");
			}
			AbstractGreetings.prototype.__ks_cons.call(this, []);
			this._greeting = greeting;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				ProxyGreetings.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_greet_0(...args) {
			return this._greeting.greet(...args);
		}
		greet() {
			return ProxyGreetings.prototype.__ks_func_greet_0.apply(this, arguments);
		}
	}
	const greetings = new ProxyGreetings(new Greetings());
	console.log(greetings.greet("John"));
};
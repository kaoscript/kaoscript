var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let Greetings = Helper.class({
		$name: "Greetings",
		$create: function() {
			this._message = "";
			this.__ks_cons(arguments);
		},
		__ks_cons_0: function() {
			Greetings.prototype.__ks_cons.call(this, ["Hello!"]);
		},
		__ks_cons_1: function(message) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(message === void 0 || message === null) {
				throw new TypeError("'message' is not nullable");
			}
			this._message = message;
		},
		__ks_cons: function(args) {
			if(args.length === 0) {
				Greetings.prototype.__ks_cons_0.apply(this);
			}
			else if(args.length === 1) {
				Greetings.prototype.__ks_cons_1.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		},
		__ks_func_greet_0: function(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			return this._message + "\nIt's nice to meet you, " + name + ".";
		},
		greet: function() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_greet_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	});
	var __ks_Greetings = {};
	let hello = new Greetings("Hello world!");
	console.log(hello.greet("miss White"));
};